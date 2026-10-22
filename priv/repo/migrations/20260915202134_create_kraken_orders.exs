defmodule CryptoDataPipeline.Repo.Migrations.CreateKrakenOrders do
  use Ecto.Migration

  def change do
    create table("kraken_order_updates", primary_key: false) do
      add :order_id, :string, size: 32, primary_key: true
      add :symbol_pair, :string, size: 16, primary_key: true
      add :event_type, :string, size: 8
      add :timestamp, :utc_datetime_usec, primary_key: true
      add :maker_side, :string, size: 4
      add :quantity, :decimal
      add :price, :decimal
    end

    execute("SELECT create_hypertable('kraken_order_updates', by_range('timestamp'))")
  end
end
