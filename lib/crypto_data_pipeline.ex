defmodule CryptoDataPipeline do
  use Application
  #require Logger

  @impl true
  def start(_type, _args) do
    children = [
      CryptoDataPipeline.Repo,
      {CryptoDataPipeline.MainServer, %{}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
