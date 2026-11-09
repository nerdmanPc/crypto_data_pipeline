defmodule CryptoDataPipeline.Repo.Migrations.CreateKrakenOrderUpdates do
  use Ecto.Migration

  def change do
    create_table = """
    CREATE TABLE kraken_order_updates (
      timestamp TIMESTAMPTZ NOT NULL,
      symbol_pair TEXT NOT NULL,
      order_id TEXT NOT NULL,
      event_type event_type NOT NULL,
      maker_side order_side NOT NULL,
      quantity NUMERIC NOT NULL,
      price NUMERIC NOT NULL,
      PRIMARY KEY (timestamp, symbol_pair, order_id)
    ) WITH (
      tsdb.hypertable,
      tsdb.partition_column = 'timestamp',
      tsdb.segmentby = 'symbol_pair',
      tsdb.orderby = 'timestamp ASC',
      tsdb.chunk_interval = '1 day'
    );
    """
    drop_table = """
    DROP TABLE kraken_order_updates;
    """
    execute(create_table, drop_table)
  end
end
