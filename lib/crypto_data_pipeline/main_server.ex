defmodule CryptoDataPipeline.MainServer do
  use GenServer

  def start_link(initial_state \\ %{}) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init(_init_arg) do
    Dotenv.load()

    init_arg = %{
      symbols: System.get_env("SYMBOL_PAIRS") |> String.split(","),
      api_key: System.get_env("KRAKEN_API_KEY"),
      api_secret: System.get_env("KRAKEN_API_SECRET")
    }

    {:ok, api_token} = Kraken.Auth.get_token(init_arg.api_key, init_arg.api_secret)
    trades_conn_args = init_arg |> Map.put(:channel, :trades) |> Map.put(:destination, self())

    orders_conn_args =
      init_arg
      |> Map.put(:channel, :orders)
      |> Map.put(:api_token, api_token)
      |> Map.put(:destination, self())

    # Start a supervisor for websocket connections
    {:ok, ws_supervisor} =
      Supervisor.start_link(
        [
          Supervisor.child_spec({Kraken.WsConnection, trades_conn_args}, id: :trades_conn),
          Supervisor.child_spec({Kraken.WsConnection, orders_conn_args}, id: :orders_conn)
        ],
        strategy: :one_for_one
      )

    {:ok, init_arg |> Map.merge(%{ws_supervisor: ws_supervisor})}
  end

  def handle_cast({:trades_snapshot, trade_data}, state) do
    trades = trade_data |> Enum.map(&trade_from_kraken_to_ecto/1)
    CryptoDataPipeline.Repo.insert_all(Kraken.Trade, trades, on_conflict: :nothing)
    {:noreply, state}
  end

  def handle_cast({:trades_update, trade_data}, state) do
    trades = trade_data |> Enum.map(&trade_from_kraken_to_ecto/1)
    CryptoDataPipeline.Repo.insert_all(Kraken.Trade, trades, on_conflict: :nothing)
    {:noreply, state}
  end

  def handle_cast({:order_book_snapshot, order_data}, state) do
    orders = order_data |> Stream.map(&item_from_kraken_to_ecto/1) |> Enum.concat()
    CryptoDataPipeline.Repo.insert_all(Kraken.OrderUpdate, orders, on_conflict: :nothing)
    {:noreply, state}
  end

  def handle_cast({:order_book_update, order_data}, state) do
    orders = order_data |> Stream.map(&item_from_kraken_to_ecto/1) |> Enum.concat()
    CryptoDataPipeline.Repo.insert_all(Kraken.OrderUpdate, orders, on_conflict: :nothing)
    {:noreply, state}
  end

  defp trade_from_kraken_to_ecto(trade) do
    %{
      trade_id: trade.trade_id,
      symbol_pair: trade.symbol,
      timestamp: DateTime.from_iso8601(trade.timestamp) |> elem(1),
      side: String.to_existing_atom(trade.side),
      quantity: trade.qty,
      price: trade.price,
      taker_order_type: String.to_existing_atom(trade.ord_type)
    }
  end

  defp item_from_kraken_to_ecto(item) do
    symbol_pair = item.symbol
    bids = item.bids |> Stream.map(&order_from_kraken_to_ecto(&1, symbol_pair, :buy))
    asks = item.asks |> Stream.map(&order_from_kraken_to_ecto(&1, symbol_pair, :sell))
    Stream.concat(bids, asks)
  end

  defp order_from_kraken_to_ecto(order, symbol_pair, side) do
    event_type = Map.get(order, :event, "snapshot")
    event_type = String.to_existing_atom(event_type)
    timestamp = DateTime.from_iso8601(order.timestamp) |> elem(1)
    %{
      order_id: order.order_id,
      event_type: event_type,
      symbol_pair: symbol_pair,
      timestamp: timestamp,
      maker_side: side,
      quantity: order.order_qty,
      price: order.limit_price
    }
  end
end
