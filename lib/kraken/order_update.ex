defmodule Kraken.OrderUpdate do
  use Ecto.Schema

  @primary_key false
  schema "kraken_order_updates" do
    field :event_timestamp, :utc_datetime_usec, primary_key: true
    field :symbol_pair, :string, primary_key: true
    field :order_id, :string, primary_key: true
    field :order_timestamp, :utc_datetime_usec
    field :event_type, Ecto.Enum, values: [:snapshot, :add, :modify, :delete]
    field :maker_side, Ecto.Enum, values: [:buy, :sell]
    field :quantity, :decimal
    field :price, :decimal
    field :msg_timestamp, :utc_datetime_usec
  end
end
