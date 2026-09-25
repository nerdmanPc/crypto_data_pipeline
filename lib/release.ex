defmodule CryptoDataPipeline.Release do
  @moduledoc """
  Release tasks for running Ecto migrations inside the Docker image.

  This is called by the container command, for example:

      /app/bin/crypto_data_pipeline eval CryptoDataPipeline.Release.migrate
  """

  @app :crypto_data_pipeline

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          Ecto.Migrator.run(repo, :up, all: true)
        end)
    end
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(repo, fn repo ->
        Ecto.Migrator.run(repo, :down, to: version)
      end)
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
