defmodule CryptoDataPipeline do
  use Application
  require Logger

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
    children = [
      CryptoDataPipeline.Repo,
      CryptoDataPipeline.Monitor,
    ]
    trade_pipelines = get_pipeline_group(config.trade_symbol_pairs, api_token, :trades)
    order_pipelines = get_pipeline_group(config.order_symbol_pairs, api_token, :orders)
    children = children ++ order_pipelines ++ trade_pipelines
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp get_pipeline_group(symbol_pairs, api_token, channel) do
    Enum.flat_map(symbol_pairs, fn symbol_pair ->
      processor_args = processor_args(channel, symbol_pair)
      connection_args = connection_args(channel, symbol_pair, api_token, processor_args.process_name)
      [
        Supervisor.child_spec({CryptoDataPipeline.DataProcessor, processor_args}, id: processor_args.process_name),
        Supervisor.child_spec({Kraken.WsConnection, connection_args}, id: connection_args.process_name)
      ]
    end)
  end

  defp load_env_config do
    kraken_api_key = get_env_variable("KRAKEN_API_KEY")
    kraken_api_secret = get_env_variable("KRAKEN_API_SECRET")
    trade_symbol_pairs = get_env_variable("TRADE_SYMBOL_PAIRS") |> String.split(",")
    order_symbol_pairs = get_env_variable("ORDER_SYMBOL_PAIRS") |> String.split(",")
    %{
      kraken_api_key: kraken_api_key,
      kraken_api_secret: kraken_api_secret,
      trade_symbol_pairs: trade_symbol_pairs,
      order_symbol_pairs: order_symbol_pairs
    }
  end

  defp get_env_variable(var_name) do
    case System.get_env(var_name) do
      nil -> raise "Environment variable '#{var_name}' is not set"
      value -> value
    end
  end

  defp get_api_token(api_key, api_secret) do
    case Kraken.Auth.get_token(api_key, api_secret) do
      {:ok, token} -> token
      {:error, reason} -> raise "Failed to get API token: #{reason}"
    end
  end

  defp connection_args(channel, symbol_pair, api_token, processor_name) do
    formatted_symbol_pair = String.replace(symbol_pair, "/", "_")
    connection_name = String.to_atom("#{channel}_connection_#{formatted_symbol_pair}")
    %{
        symbols: [symbol_pair],
        channel: channel,
        api_token: api_token,
        destination: processor_name,
        process_name: connection_name,
      }
  end

  defp processor_args(channel, symbol_pair) do
    formatted_symbol_pair = String.replace(symbol_pair, "/", "_")
    processor_name = String.to_atom("#{channel}_processor_#{formatted_symbol_pair}")
    %{
        symbols: [symbol_pair],
        channel: channel,
        process_name: processor_name
      }
  end
end
