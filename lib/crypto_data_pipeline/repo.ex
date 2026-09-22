defmodule CryptoDataPipeline.Repo do
  use Ecto.Repo,
    otp_app: :crypto_data_pipeline,
    adapter: Ecto.Adapters.Postgres
end
