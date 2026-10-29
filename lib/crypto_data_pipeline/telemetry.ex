defmodule CryptoDataPipeline.Telemetry do
  require Logger
  def handle_telemetry(event_name, measurements, metadata, _config) do
    Logger.info("Telemetry Event - #{inspect(event_name)}:\n#{inspect(measurements)}", metadata: Keyword.new(metadata))
  end
end
