defmodule CryptoDataPipeline do
  use Application
  #require Logger

  @impl true
  def start(_type, _args) do
    :telemetry.attach(
      "queue_monitor",
      [:crypto_data_pipeline, :monitor, :message_queue_lengths],
      &CryptoDataPipeline.Telemetry.handle_telemetry/4,
      nil
    )
    config = load_env_config()
    api_token = get_api_token(config.kraken_api_key, config.kraken_api_secret)
    trades_processor_args = %{
      symbols: config.symbol_pairs,
      channel: :trades,
      process_name: :trades_processor
    }
    trades_connection_args = %{
      symbols: config.symbol_pairs,
      channel: :trades,
      destination: :trades_processor,
      process_name: :trades_connection,
      api_token: api_token,
    }
    children = [
      CryptoDataPipeline.Repo,
      CryptoDataPipeline.Monitor,
      Supervisor.child_spec({CryptoDataPipeline.DataProcessor, trades_processor_args}, id: trades_processor_args.process_name),
      Supervisor.child_spec({Kraken.WsConnection, trades_connection_args}, id: trades_connection_args.process_name),
    ]
    order_pipelines = Enum.flat_map(config.symbol_pairs, fn symbol_pair ->
      processor_args = order_processor_args(symbol_pair)
      connection_args = order_connection_args(symbol_pair, api_token, processor_args.process_name)
      [
        Supervisor.child_spec({CryptoDataPipeline.DataProcessor, processor_args}, id: processor_args.process_name),
        Supervisor.child_spec({Kraken.WsConnection, connection_args}, id: connection_args.process_name)
      ]
    end)
    children = children ++ order_pipelines
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp load_env_config do
    Dotenv.load()
    kraken_api_key = System.get_env("KRAKEN_API_KEY")
    kraken_api_secret = System.get_env("KRAKEN_API_SECRET")
    symbol_pairs = System.get_env("SYMBOL_PAIRS") |> String.split(",")
    %{kraken_api_key: kraken_api_key, kraken_api_secret: kraken_api_secret, symbol_pairs: symbol_pairs}
  end

  defp get_api_token(api_key, api_secret) do
    case Kraken.Auth.get_token(api_key, api_secret) do
      {:ok, token} -> token
      {:error, reason} -> raise "Failed to get API token: #{reason}"
    end
  end

  defp order_connection_args(symbol_pair, api_token, processor_name) do
    formatted_symbol_pair = String.replace(symbol_pair, "/", "_")
    connection_name = String.to_atom("orders_connection_#{formatted_symbol_pair}")
    %{
        symbols: [symbol_pair],
        channel: :orders,
        api_token: api_token,
        destination: processor_name,
        process_name: connection_name,
      }
  end

  defp order_processor_args(symbol_pair) do
    formatted_symbol_pair = String.replace(symbol_pair, "/", "_")
    processor_name = String.to_atom("orders_processor_#{formatted_symbol_pair}")
    %{
        symbols: [symbol_pair],
        channel: :orders,
        process_name: processor_name
      }
  end
end
