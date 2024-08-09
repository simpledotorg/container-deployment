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

local database_queries =
  utils.row('Database Queries', [
    utils.table('Max Runtime (Top N)', [
      query(
        |||
          max(max_over_time(ccp_pg_stat_statements_top_max_exec_time_ms{}[$__range])) without(instance, ip, deployment, pod)
        |||
      ) +
      g.query.prometheus.withInstant(true) +
      g.query.prometheus.withFormat('table'),
    ]),
    utils.table('Mean Runtime (Top N)', [
      query(
        |||
          avg(avg_over_time(ccp_pg_stat_statements_top_max_exec_time_ms{}[$__range])) without(instance, ip, deployment, pod)
        |||
      ) +
      g.query.prometheus.withInstant(true) +
      g.query.prometheus.withFormat('table'),
    ]),
    utils.table('Total Runtime (Top N)', [
      query(
        |||
          max(max_over_time(ccp_pg_stat_statements_top_max_exec_time_ms{}[$__range])) without(instance, ip, deployment, pod)
        |||
      ) +
      g.query.prometheus.withInstant(true) +
      g.query.prometheus.withFormat('table'),
    ]),
  ]);

g.dashboard.new('Simple Database Dashboard')
+ g.dashboard.withUid('simple-database-dashboard')
+ g.dashboard.withDescription('Simple database dashboard')
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withVariables([utils.datasource])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    database,
    database_queries,
  ])
)
