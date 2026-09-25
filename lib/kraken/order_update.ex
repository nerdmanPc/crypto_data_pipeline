defmodule Kraken.OrderUpdate do
  use Ecto.Schema

  schema "kraken_order_updates" do
    field :order_id, :string
    field :event_type, Ecto.Enum, values: [:snapshot, :add, :modify, :delete]
    field :symbol_pair, :string
    field :timestamp, :utc_datetime_usec
    field :maker_side, Ecto.Enum, values: [:buy, :sell]
    field :quantity, :decimal
    field :price, :decimal
  end
end
