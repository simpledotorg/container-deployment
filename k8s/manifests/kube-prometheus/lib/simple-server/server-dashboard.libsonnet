local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local row(title, panels) =
  g.panel.row.new(title)
  + g.panel.row.withPanels(panels);

local timeSeries(title, queries) =
  g.panel.timeSeries.new(title)
  + g.panel.timeSeries.queryOptions.withTargets(queries);

local stat(title, queries) =
  g.panel.stat.new(title)
  + g.panel.stat.queryOptions.withTargets(queries)
  + g.panel.stat.options.withJustifyMode('center');

local stateTimeline(title, queries, thresholds) =
  g.panel.stateTimeline.new(title)
  + g.panel.stateTimeline.queryOptions.withTargets(queries)
  + g.panel.stateTimeline.standardOptions.thresholds.withMode('absolute')
  + g.panel.stateTimeline.standardOptions.thresholds.withSteps(thresholds);

local barGauge(title, queries) =
  g.panel.barGauge.new(title)
  + g.panel.barGauge.queryOptions.withTargets(queries);

local query(query, label=null) =
  if label == null then
    g.query.prometheus.new('${datasource}', query)
  else
    g.query.prometheus.new('${datasource}', query)
    + g.query.prometheus.withLegendFormat('Total');

local datasource = g.dashboard.variable.datasource.new('datasource', 'prometheus');

local slos =
  g.panel.row.new('SLOs')
  + g.panel.row.withPanels([
    stateTimeline(
      'P95 Response Time < 1.2s',
      [
        query('simple:response_time:p95:total', 'All'),
        query('simple:response_time:p95:api', 'API'),
        query('simple:response_time:p95:dashboard', 'Dashboard'),
      ],
      [{ color: 'green', value: null }, { color: 'red', value: 1.2 }]
    ) + g.panel.stateTimeline.panelOptions.withGridPos(w='24'),
    stat('Healthy hosts', [
      query(
        |||
          count(kube_pod_info{namespace="simple-v1",created_by_name="simple-server"})
        |||
      ) + g.query.prometheus.withLegendFormat('Server'),
      query(
        |||
          count(kube_pod_info{namespace="simple-v1",created_by_name="simple-worker"})
        |||
      ) + g.query.prometheus.withLegendFormat('Worker'),
    ]),
  ]);

local load_balancer =
  row('Load Balancer', [
    timeSeries('Request Rate', [
      query('sum(rate(ruby_http_request_duration_seconds_count[$__rate_interval])) > 0', 'All'),
      query('sum(rate(ruby_http_request_duration_seconds_count{controller=~"api/.+"}[$__rate_interval])) > 0', 'API'),
      query('sum(rate(ruby_http_request_duration_seconds_count{controller!~"api/.+"}[$__rate_interval])) > 0', 'Dashboard'),
    ])
    + g.panel.timeSeries.fieldConfig.defaults.custom.withAxisLabel('Req/sec')
    + g.panel.timeSeries.options.legend.withIsVisible(false),
    timeSeries('Non 2xx', [
      query('sum by(status) (rate(ruby_http_requests_total{status!~"2.."}[$__rate_interval])) > 0', 'All'),
      query('sum by(status) (rate(ruby_http_requests_total{status!~"2..",controller=~"api/.+"}[$__rate_interval])) > 0', 'API'),
      query('sum by(status) (rate(ruby_http_requests_total{status!~"2..",controller!~"api/.+"}[$__rate_interval])) > 0', 'Dashboard'),
    ]),
    timeSeries('Response Time', [
      query(
        |||
          sum(irate(ruby_http_request_duration_seconds_sum[$__rate_interval])
            / irate(ruby_http_request_duration_seconds_count[$__rate_interval]) > 0)
        |||, 'All'
      ),
      query(
        |||
          sum(irate(ruby_http_request_duration_seconds_sum{controller=~"api/.+"}[$__rate_interval])
            / irate(ruby_http_request_duration_seconds_count{controller=~"api/.+"}[$__rate_interval]) > 0)
        |||, 'All'
      ),
      query(
        |||
          sum(irate(ruby_http_request_duration_seconds_sum{controller!~"api/.+"}[$__rate_interval])
            / irate(ruby_http_request_duration_seconds_count{controller!~"api/.+"}[$__rate_interval]) > 0)
        |||, 'All'
      ),
    ]),
    barGauge('Nginx Connections', [
      query(
        |||
          sum by(state) (nginx_ingress_controller_nginx_process_connections)
        |||, '{{state}}'
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
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withVariables([datasource])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    slos,
    load_balancer,
    // sync_to_user,
    // sync_from_user,
    // database,
  ])
)
