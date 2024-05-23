local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local row(title, panels) =
  g.panel.row.new(title)
  + g.panel.row.withPanels(panels);

local timeSeries(title, queries) =
  g.panel.timeSeries.new(title)
  + g.panel.timeSeries.queryOptions.withTargets(queries);

local query(query) = g.query.prometheus.new('${datasource}', query);

local datasource = g.dashboard.variable.datasource.new('datasource', 'prometheus');

local slos =
  g.panel.row.new('SLOs')
  + g.panel.row.withPanels([
    g.panel.timeSeries.new('SLO: Dashboard p95 latency is under 1.2 seconds'),
  ]);

local load_balancer =
  row('Load Balancer', [
    timeSeries(
      'Request Rate', [query(
        |||
          sum(rate(nginx_ingress_controller_requests[$__rate_interval])) 
        |||
      )],
    ),
    timeSeries('Non 2xx', [
      query(
        |||
          sum(rate(nginx_ingress_controller_requests{status=~"3.."}[$__rate_interval]))
        |||
      ),
      query(
        |||
          sum(rate(nginx_ingress_controller_requests{status=~"4.."}[$__rate_interval]))
        |||
      ),
      query(
        |||
          sum(rate(nginx_ingress_controller_requests{status=~"5.."}[$__rate_interval]))
        |||
      ),
    ]),
    timeSeries('Latency', [
      query(
        |||
          sum by(ingress) (nginx_ingress_controller_ingress_upstream_latency_seconds{quantile="0.99"})
        |||
      ),
    ]),
    timeSeries('Healthy hosts', [
      query(
        |||
          count(nginx_ingress_controller_build_info)
        |||
      ),
    ]),
    timeSeries('Healthy hosts', [
      query(
        |||
          count(nginx_ingress_controller_build_info)
        |||
      ),
    ]),
    timeSeries('Connections: reading, writing, waiting', [
      query(
        |||
          sum by(state) (nginx_ingress_controller_nginx_process_connections{state!="active"})
        |||
      ),
    ]),
    timeSeries('Connections: Active', [
      query(
        |||
          sum by(state) (nginx_ingress_controller_nginx_process_connections{state="active"})
        |||
      ),
    ]),
  ]);

local sync_to_user =
  row('Sync To User', [
    timeSeries(
      'Request Rate', [query(
        |||
          sum by(controller) (rate(ruby_http_requests_total{action="sync_to_user"}[$__rate_interval]))
        |||
      )],
    ),
    timeSeries('Latency', [
      query(
        |||
          sum by(controller) (rate(ruby_http_request_duration_seconds_sum{action="sync_to_user"}[$__rate_interval])) * 1000
        |||
      ),
    ]),
    timeSeries('Error Rate', [
      query(
        |||
          sum by(status) (rate(ruby_http_requests_total{action="sync_to_user", status!~"2.."}[$__rate_interval]))
        |||
      ),
    ]),
  ]);

local sync_from_user =
  row('Sync From User', [
    timeSeries(
      'Request Rate', [query(
        |||
          sum by(controller) (rate(ruby_http_requests_total{action="sync_from_user"}[$__rate_interval]))
        |||
      )],
    ),
    timeSeries('Latency', [
      query(
        |||
          sum by(controller) (rate(ruby_http_request_duration_seconds_sum{action="sync_from_user"}[$__rate_interval])) * 1000
        |||
      ),
    ]),
    timeSeries('Error Rate', [
      query(
        |||
          sum by(status) (rate(ruby_http_requests_total{action="sync_from_user", status!~"2.."}[$__rate_interval]))
        |||
      ),
    ]),
  ]);

local database =
  row('Database', [
    timeSeries(
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
    timeSeries(
      'Latency', [
        query(
          |||
            sum by(dbname) (ccp_pg_stat_statements_total_mean_exec_time_ms)
          |||
        ),
      ],
    ),
    timeSeries(
      'Active Connections', [
        query(
          |||
            ccp_connection_stats_active
          |||
        ),
      ],
    ),
    timeSeries(
      'CPU Usage', [
        query(
          |||
            sum by(pod) (ccp_nodemx_cpu_request)
          |||
        ),
      ],
    ),
    timeSeries(
      'Memory Usage', [
        query(
          |||
            sum by(pod) (ccp_nodemx_mem_usage_in_bytes)
          |||
        ),
      ],
    ),
    timeSeries(
      'Available disk space', [
        query(
          |||
            sum by(pod) (ccp_nodemx_data_disk_available_bytes)
          |||
        ),
      ],
    ),
    timeSeries(
      'Query Rate', [
        query(
          |||
            sum by(dbname) (rate(ccp_pg_stat_statements_total_calls_count[$__rate_interval]))
          |||
        ),
      ],
    ),
    timeSeries(
      'Database Size', [
        query(
          |||
            sum by(dbname) (ccp_database_size_bytes)
          |||
        ),
      ],
    ),
  ]);

g.dashboard.new('Simple Server Dasboard')
+ g.dashboard.withUid('simple-server-dashboard')
+ g.dashboard.withDescription('Simple server dashboard')
+ g.dashboard.withVariables([datasource])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    slos,
    load_balancer,
    sync_to_user,
    sync_from_user,
    database,
  ])
)
