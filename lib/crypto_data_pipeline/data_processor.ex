defmodule CryptoDataPipeline.DataProcessor do
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: initial_state.process_name)
  end

  def init(init_arg) do
    state =
      init_arg
      |> Map.put_new(:buffer, [])
      |> Map.put_new(:flush_interval_ms, 100)

    Process.send_after(self(), :flush_buffer, state.flush_interval_ms)
    {:ok, state}
  end

  def handle_cast({:trades_snapshot, trade_data}, state) do
    msg_timestamp = DateTime.utc_now(:microsecond)
    {:noreply, add_to_buffer(state, build_trade_rows(trade_data, msg_timestamp))}
  end

  def handle_cast({:trades_update, trade_data}, state) do
    msg_timestamp = DateTime.utc_now(:microsecond)
    {:noreply, add_to_buffer(state, build_trade_rows(trade_data, msg_timestamp))}
  end

  def handle_cast({:order_book_snapshot, order_data}, state) do
    msg_timestamp = DateTime.utc_now(:microsecond)
    {:noreply, add_to_buffer(state, build_order_rows(order_data, msg_timestamp))}
  end

  def handle_cast({:order_book_update, order_data}, state) do
    msg_timestamp = DateTime.utc_now(:microsecond)
    {:noreply, add_to_buffer(state, build_order_rows(order_data, msg_timestamp))}
  end

  def handle_info(:flush_buffer, state) do
    state =
      case state.buffer do
        [] ->
          Process.send_after(self(), :flush_buffer, state.flush_interval_ms)
          state

        rows ->
          flush_buffer(rows, state)
      end

    {:noreply, state}
  end

  defp add_to_buffer(state, rows) do
    Map.update(state, :buffer, rows, &(&1 ++ rows))
  end

  defp build_trade_rows(trade_data, msg_timestamp) do
    Enum.map(trade_data, &trade_from_kraken_to_ecto(&1, msg_timestamp))
  end

  defp build_order_rows(order_data, msg_timestamp) do
    order_data
    |> Stream.map(&item_from_kraken_to_ecto(&1, msg_timestamp))
    |> Enum.concat()
    |> Enum.to_list()
  end

  defp flush_buffer(rows, state) do
    case state.channel do
      :trades ->
        CryptoDataPipeline.Repo.insert_all(Kraken.Trade, rows, on_conflict: :nothing)
      :orders ->
        CryptoDataPipeline.Repo.insert_all(Kraken.OrderUpdate, rows, on_conflict: :nothing)
      _ ->
        :ok
    end

    Process.send_after(self(), :flush_buffer, state.flush_interval_ms)
    Map.put(state, :buffer, [])
  end

  defp trade_from_kraken_to_ecto(trade, msg_timestamp) do
    %{
      trade_id: trade.trade_id,
      symbol_pair: trade.symbol,
      timestamp: DateTime.from_iso8601(trade.timestamp) |> elem(1),
      taker_side: String.to_existing_atom(trade.side),
      quantity: trade.qty,
      price: trade.price,
      taker_order_type: String.to_existing_atom(trade.ord_type),
      msg_timestamp: msg_timestamp,
    }
  end

  defp item_from_kraken_to_ecto(item, msg_timestamp) do
    symbol_pair = item.symbol
    event_timestamp = DateTime.from_iso8601(item.timestamp) |> elem(1)
    bids = item.bids |> Stream.map(&order_from_kraken_to_ecto(&1, symbol_pair, :buy, msg_timestamp, event_timestamp))
    asks = item.asks |> Stream.map(&order_from_kraken_to_ecto(&1, symbol_pair, :sell, msg_timestamp, event_timestamp))
    Stream.concat(bids, asks) |> Enum.to_list()
  end

  defp order_from_kraken_to_ecto(order, symbol_pair, side, msg_timestamp, event_timestamp) do
    event_type = Map.get(order, :event, "snapshot")
    event_type = String.to_existing_atom(event_type)
    timestamp = DateTime.from_iso8601(order.timestamp) |> elem(1)

    %{
      order_id: order.order_id,
      event_type: event_type,
      symbol_pair: symbol_pair,
      order_timestamp: timestamp,
      maker_side: side,
      quantity: order.order_qty,
      price: order.limit_price,
      msg_timestamp: msg_timestamp,
      event_timestamp: event_timestamp,
    }
  end
end
