defmodule CryptoDataPipeline.MixProject do
  use Mix.Project

  def project do
    [
      app: :crypto_data_pipeline,
      version: "0.1.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {CryptoDataPipeline, []},
      extra_applications: [:logger]
    ]
  end

  defp releases do
    [
      crypto_data_pipeline: [
        include_erts: true,
        steps: [:assemble, :tar]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.14"},
      {:postgrex, "~> 0.22.4"},
      {:jason, "~> 1.4"},
      {:decimal, "~> 3.1"},
      {:websockex, "~> 0.4"},
      {:req, "~> 0.7.4"},
      {:dotenv, "~> 3.1"},
      {:mox, "~> 1.2", only: :test}
    ]
  end
end
