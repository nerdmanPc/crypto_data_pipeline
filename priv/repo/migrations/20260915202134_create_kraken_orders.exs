defmodule CryptoDataPipeline.Repo.Migrations.CreateKrakenOrders do
  use Ecto.Migration

  def change do
    create table("kraken_order_updates") do
      add :order_id, :string
      add :event_type, :string
      add :symbol_pair, :string
      add :timestamp, :utc_datetime_usec
      add :maker_side, :string
      add :quantity, :decimal
      add :price, :decimal
    end
  end
end
