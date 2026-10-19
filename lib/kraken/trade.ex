defmodule Kraken.Trade do
  use Ecto.Schema

  @primary_key false
  schema "kraken_trades" do
    field :trade_id, :integer, primary_key: true
    field :symbol_pair, :string, primary_key: true
    field :timestamp, :utc_datetime_usec
    field :side, Ecto.Enum, values: [:buy, :sell]
    field :quantity, :decimal
    field :price, :decimal
    field :taker_order_type, Ecto.Enum, values: [:market, :limit]
  end
end
