defmodule CryptoDataPipeline.Repo.Migrations.CreateKrakenOrders do
  use Ecto.Migration

  def change do
    create table("kraken_order_updates", primary_key: false) do
      add :order_id, :string, primary_key: true
      add :symbol_pair, :string, primary_key: true
      add :event_type, :string
      add :timestamp, :utc_datetime_usec
      add :maker_side, :string
      add :quantity, :decimal
      add :price, :decimal
    end

    execute("SELECT create_hypertable('kraken_order_updates', 'timestamp')")
  end
end
