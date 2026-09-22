import Config
import_config "#{config_env()}.exs"

config :crypto_data_pipeline, CryptoDataPipeline.Repo,
  database: "crypto_data_repository",
  username: "crypto_data_pipeline",
  password: "#{System.get_env("POSTGRES_PASSWORD")}",
  hostname: "timescaledb"

config :crypto_data_pipeline, ecto_repos: [CryptoDataPipeline.Repo]
