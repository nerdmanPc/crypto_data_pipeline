defmodule CryptoDataPipeline.Repo.Migrations.CreateEnumTypes do
  use Ecto.Migration

  def change do
    execute("CREATE TYPE event_type AS ENUM ('snapshot', 'add', 'modify', 'delete')", "DROP TYPE event_type")
    execute("CREATE TYPE order_side AS ENUM ('buy', 'sell')", "DROP TYPE order_side")
    execute("CREATE TYPE order_type AS ENUM ('market', 'limit')", "DROP TYPE order_type")
  end
end
