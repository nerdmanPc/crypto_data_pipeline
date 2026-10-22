defmodule CryptoDataPipeline.Repo.Migrations.CreateKrakenTrades do
  use Ecto.Migration

  def change do
    create table("kraken_trades", primary_key: false) do
      add :trade_id, :integer, primary_key: true
      add :symbol_pair, :string, size: 16, primary_key: true
      add :timestamp, :utc_datetime_usec, primary_key: true
      add :side, :string, size: 4
      add :quantity, :decimal
      add :price, :decimal
      add :taker_order_type, :string, size: 6
    end

    execute("SELECT create_hypertable('kraken_trades', by_range('timestamp'))")
  end
end
