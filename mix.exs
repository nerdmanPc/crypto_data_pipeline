defmodule CryptoDataPipeline.MixProject do
  use Mix.Project

  def project do
    [
      app: :crypto_data_pipeline,
      version: "0.1.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {CryptoDataPipeline.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:decimal, "~> 3.1"},
      {:websockex, "~> 0.4"},
      {:req, "~> 0.6"},
      {:dotenv, "~> 3.1"},
      {:mox, "~> 1.2", only: :test}
    ]
  end
end
