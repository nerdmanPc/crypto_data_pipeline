defmodule CryptoDataPipeline.Repo.Migrations.CreateKrakenTrades do
  use Ecto.Migration

  def change do
    #Logger.AppLogger.info("Creating kraken_trades table")
    #Logger.AppLogger.info("Password:  #{System.get_env("POSTGRES_PASSWORD")}")
    create table("kraken_trades") do
      add :trade_id, :integer
      add :symbol_pair, :string
      add :timestamp, :utc_datetime_usec
      add :side, :string
      add :quantity, :decimal
      add :price, :decimal
      add :taker_order_type, :string
    end
  end
end
