defmodule CryptoDataPipeline.Repo.Migrations.CreateKrakenTrades do
  use Ecto.Migration

  def change do
    create table("kraken_trades", primary_key: false) do
      add :trade_id, :integer, primary_key: true
      add :symbol_pair, :string, primary_key: true
      add :timestamp, :utc_datetime_usec, primary_key: true
      add :side, :string
      add :quantity, :decimal
      add :price, :decimal
      add :taker_order_type, :string
    end

    execute("SELECT create_hypertable('kraken_trades', by_range('timestamp'))")
  end
end
