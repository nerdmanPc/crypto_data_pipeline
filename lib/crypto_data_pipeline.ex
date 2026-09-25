defmodule CryptoDataPipeline do
  use Application
  #require Logger

  @impl true
  def start(_type, _args) do
    children = [
      CryptoDataPipeline.Repo,
      {CryptoDataPipeline.MainServer, %{}}
    ]

    #Logger.debug("Postgres Password: #{System.get_env("POSTGRES_PASSWORD")}")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
