local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local utils = (import './dashboard-utils.libsonnet');
local query = utils.query;

local database =
  utils.row('Database', [
    utils.timeSeries(
      'Throughput', [
        query(
          |||
            ccp_nodemx_network_tx_bytes
          |||
        ),
        query(
          |||
            ccp_nodemx_network_rx_bytes
          |||
        ),
      ],
    ),
    utils.timeSeries(
      'Latency', [
        query(
          |||
            sum by(dbname) (ccp_pg_stat_statements_total_mean_exec_time_ms)
          |||
        ),
      ],
    ),
    utils.timeSeries(
      'Active Connections', [
        query(
          |||
            ccp_connection_stats_active
          |||
        ),
      ],
    ),
    utils.timeSeries(
      'CPU Usage', [
        query(
          |||
            sum by(pod) (ccp_nodemx_cpu_request)
          |||
        ),
      ],
    ),
    utils.timeSeries(
      'Memory Usage', [
        query(
          |||
            sum by(pod) (ccp_nodemx_mem_usage_in_bytes)
          |||
        ),
      ],
    ),
    utils.timeSeries(
      'Available disk space', [
        query(
          |||
            sum by(pod) (ccp_nodemx_data_disk_available_bytes)
          |||
        ),
      ],
    ),
    utils.timeSeries(
      'Query Rate', [
        query(
          |||
            sum by(dbname) (rate(ccp_pg_stat_statements_total_calls_count[$__rate_interval]))
          |||
        ),
      ],
    ),
    utils.timeSeries(
      'Database Size', [
        query(
          |||
            sum by(dbname) (ccp_database_size_bytes)
          |||
        ),
      ],
    ),
  ]);

g.dashboard.new('Simple Database Dashboard')
+ g.dashboard.withUid('simple-database-dashboard')
+ g.dashboard.withDescription('Simple database dashboard')
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withVariables([utils.datasource])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    database,
  ])
)
