defmodule Kraken.OrderUpdate do
  use Ecto.Schema

  @primary_key false
  schema "kraken_order_updates" do
    field :order_id, :string, primary_key: true
    field :symbol_pair, :string, primary_key: true
    field :event_type, Ecto.Enum, values: [:snapshot, :add, :modify, :delete]
    field :timestamp, :utc_datetime_usec
    field :maker_side, Ecto.Enum, values: [:buy, :sell]
    field :quantity, :decimal
    field :price, :decimal
  end
end
