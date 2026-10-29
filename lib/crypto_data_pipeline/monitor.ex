defmodule CryptoDataPipeline.Monitor do
  use GenServer

  @default_interval_ms 5_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    interval_ms =
      Keyword.get(
        opts,
        :interval_ms,
        Application.get_env(:crypto_data_pipeline, :monitor_interval_ms, @default_interval_ms)
      )

    schedule_check(interval_ms)
    {:ok, %{interval_ms: interval_ms}}
  end

  def handle_info(:check_message_queues, state) do
    report_queue_lengths()
    schedule_check(state.interval_ms)
    {:noreply, state}
  end

  defp schedule_check(interval_ms) do
    Process.send_after(self(), :check_message_queues, interval_ms)
  end

  defp report_queue_lengths do
    processes =
      Process.list()
      |> Stream.map(&process_snapshot/1)
      |> Stream.reject(&is_nil/1)
      |> Stream.filter(&(&1.message_queue_len > 1))
      |> Enum.sort_by(& &1.message_queue_len, :desc)

    :telemetry.execute(
      [:crypto_data_pipeline, :monitor, :message_queue_lengths],
      %{processes: processes},
      %{interval_ms: @default_interval_ms}
    )
  end

  defp process_snapshot(pid) do
    case Process.info(pid, [:message_queue_len, :registered_name]) do

      [{:message_queue_len, len}, {:registered_name, name}] ->
        %{
          pid: pid,
          message_queue_len: len,
          registered_name: name,
        }

      [{:message_queue_len, len}] ->
        %{
          pid: pid,
          message_queue_len: len,
          registered_name: nil,
        }
      _ ->
        nil
    end
  end
end
