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
    children = [
      CryptoDataPipeline.Monitor,
      CryptoDataPipeline.Repo,
      {CryptoDataPipeline.MainServer, %{}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
