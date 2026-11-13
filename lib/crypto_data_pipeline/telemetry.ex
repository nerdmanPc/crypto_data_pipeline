defmodule CryptoDataPipeline.Telemetry do
  require Logger

  def handle_telemetry([:monitor, :message_queue_lengths], measurements, _metadata, _config) do
    if length(measurements.processes) > 0 do
      log_queue_lengths(measurements)
    end
  end

  def handle_telemetry(event_name, measurements, metadata, _config) do
    Logger.warning("Unknown Telemetry Event - #{inspect(event_name, pretty: true)}:\n#{inspect(measurements, pretty: true)}", metadata: Keyword.new(metadata))
  end

  defp log_queue_lengths(measurements) do
    header = "Processes with message queue lengths exceeding threshold:\n"
    body = Enum.map_join(measurements.processes, "\n", &format_process_info/1)
    Logger.warning(header <> body)
  end

  defp format_process_info(%{pid: pid, message_queue_len: len, registered_name: name}) do
    "\tPID: #{inspect(pid)}, Name: #{inspect(name)}, Queue Length: #{len}"
  end
end
