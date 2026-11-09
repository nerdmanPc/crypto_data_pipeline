defmodule CryptoDataPipeline.Repo.Migrations.CreateKrakenTrades do
  use Ecto.Migration

  def change do
    create_table = """
    CREATE TABLE kraken_trades (
      timestamp TIMESTAMPTZ NOT NULL,
      symbol_pair TEXT NOT NULL,
      trade_id BIGINT NOT NULL,
      side order_side NOT NULL,
      quantity NUMERIC NOT NULL,
      price NUMERIC NOT NULL,
      taker_order_type order_type NOT NULL,
      PRIMARY KEY (timestamp, symbol_pair, trade_id)
    ) WITH (
      tsdb.hypertable,
      tsdb.partition_column = 'timestamp',
      tsdb.segmentby = 'symbol_pair',
      tsdb.orderby = 'timestamp ASC',
      tsdb.chunk_interval = '7 days'
    );
    """
    drop_table = """
    DROP TABLE kraken_trades;
    """
    execute(create_table, drop_table)
  end
end
