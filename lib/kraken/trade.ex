defmodule Kraken.Trade do
  use Ecto.Schema

  schema "kraken_trades" do
    field :trade_id, :integer
    field :symbol_pair, :string
    field :timestamp, :utc_datetime_usec
    field :side, Ecto.Enum, values: [:buy, :sell]
    field :quantity, :decimal
    field :price, :decimal
    field :taker_order_type, Ecto.Enum, values: [:market, :limit]
  end
end
