local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local utils = (import './dashboard-utils.libsonnet');
local query = utils.query;

/* -------------------------
   POD ROW
-------------------------- */
local pod =
  utils.row('Pod', [
    utils.timeSeries(
      'Pod Memory',
      [
        query('ruby_collector_rss'),
      ]
    )
    + g.panel.timeSeries.panelOptions.withGridPos(w=8, h=8) 
  ]);

/* -------------------------
   SLOS & APPLICATION HEALTH
-------------------------- */
local slos =
  g.panel.row.new('SLOs')
  + g.panel.row.withPanels([
    // New metrics added from target JSON
    utils.timeSeries('Authentication Failure Rate (401 errors)', [
      query('sum(rate(ruby_http_requests_total{status="401"}[5m]))'),
    ]) + g.panel.timeSeries.panelOptions.withGridPos(w=12, h=8), 

    utils.timeSeries('Average Latency', [
      query('rate(ruby_http_request_duration_seconds_sum[5m]) / rate(ruby_http_request_duration_seconds_count[5m])'),
    ]) + g.panel.timeSeries.panelOptions.withGridPos(w=12, h=8), 

    utils.timeSeries('Top 5 Slowest DB Models/Operations', [
      query('topk(5, sum by (model, operation) (ruby_sync_to_user_operation_duration_seconds))'),
    ]) + g.panel.timeSeries.panelOptions.withGridPos(w=12, h=8), 

    utils.timeSeries('Latency Heatmap', [
      query('sum by (operation) (rate(ruby_sync_to_user_operation_duration_seconds[5m]))'),
    ]) + g.panel.timeSeries.panelOptions.withGridPos(w=12, h=8), 

    utils.timeSeries('p99 Latency', [
      query('ruby_http_request_duration_seconds{quantile="0.99"}'),
    ]) + g.panel.timeSeries.panelOptions.withGridPos(w=12, h=8), 

    utils.timeSeries('Error Rate (5xx errors)', [
      query('sum(rate(ruby_http_requests_total{status=~"5.."}[5m])) / sum(rate(ruby_http_requests_total[5m])) * 100'),
    ]) + g.panel.timeSeries.panelOptions.withGridPos(w=12, h=8), 

    // Original SLO panels
    utils.stateTimeline(
      'P95 Response Time < 1.2s',
      [
        query('simple:response_time:p95:total', 'All'),
        query('simple:response_time:p95:api', 'API'),
        query('simple:response_time:p95:dashboard', 'Dashboard'),
      ],
      [{ color: 'green', value: null }, { color: 'red', value: 1.2 }]
    ) + g.panel.stateTimeline.panelOptions.withGridPos(w=8, h=8), [cite: 14, 22]

    utils.stat('Healthy hosts', [
      query('count(kube_pod_info{namespace="simple-v1",created_by_name="simple-server"})') + g.query.prometheus.withLegendFormat('Server'),
      query('count(kube_pod_info{namespace="simple-v1",created_by_name="simple-worker"})') + g.query.prometheus.withLegendFormat('Worker'),
    ]) + g.panel.stat.panelOptions.withGridPos(w=8, h=8), [cite: 15, 22]
  ]);

/* -------------------------
   LOAD BALANCER
-------------------------- */
local load_balancer =
  utils.row('Load Balancer', [
    utils.timeSeries('Request Rate', [
      query('sum(rate(ruby_http_request_duration_seconds_count[$__rate_interval])) > 0', 'All'),
      query('sum(rate(ruby_http_request_duration_seconds_count{controller=~"api/.+"}[$__rate_interval])) > 0', 'API'),
      query('sum(rate(ruby_http_request_duration_seconds_count{controller!~"api/.+"}[$__rate_interval])) > 0', 'Dashboard'),
    ])
    + g.panel.timeSeries.fieldConfig.defaults.custom.withAxisLabel('Req/sec')
    + g.panel.timeSeries.standardOptions.withUnit('reqps')
    + g.panel.timeSeries.options.legend.withIsVisible(false), [cite: 16]

    utils.timeSeries('Non 2xx', [
      query('sum by(status) (rate(ruby_http_requests_total{status!~"2.."}[$__rate_interval])) > 0', 'All {{status}}'),
      query('sum by(status) (rate(ruby_http_requests_total{status!~"2..",controller=~"api/.+"}[$__rate_interval])) > 0', 'API {{status}}'),
      query('sum by(status) (rate(ruby_http_requests_total{status!~"2..",controller!~"api/.+"}[$__rate_interval])) > 0', 'Dashboard {{status}}'), [cite: 16, 17]
    ]),

    utils.timeSeries('Response Time', [
      query('sum(irate(ruby_http_request_duration_seconds_sum[$__rate_interval]) / irate(ruby_http_request_duration_seconds_count[$__rate_interval]) > 0)', 'All'),
      query('sum(irate(ruby_http_request_duration_seconds_sum{controller=~"api/.+"}[$__rate_interval]) / irate(ruby_http_request_duration_seconds_count{controller=~"api/.+"}[$__rate_interval]) > 0)', 'API'),
      query('sum(irate(ruby_http_request_duration_seconds_sum{controller!~"api/.+"}[$__rate_interval]) / irate(ruby_http_request_duration_seconds_count{controller!~"api/.+"}[$__rate_interval]) > 0)', 'Dashboard'), [cite: 17, 18]
    ])
    + g.panel.timeSeries.standardOptions.withUnit('s'), [cite: 18]

    utils.barGauge('Nginx Connections', [
      query('sum by(state) (nginx_ingress_controller_nginx_process_connections)', '{{state}}'), [cite: 18]
    ]),

    utils.table('Slow actions in selected range', [
      query('topk(10, avg((rate(ruby_http_request_duration_seconds_sum[$__range]) / rate(ruby_http_request_duration_seconds_count[$__range]))) by (controller, action))')
      + g.query.prometheus.withInstant(true)
      + g.query.prometheus.withFormat('table'), [cite: 18]
    ]),

    utils.table('Slow actions in last 24 hours', [
      query('topk(10, avg((rate(ruby_http_request_duration_seconds_sum[1d]) / rate(ruby_http_request_duration_seconds_count[1d]))) by (controller, action))')
      + g.query.prometheus.withInstant(true)
      + g.query.prometheus.withFormat('table'), [cite: 18, 19]
    ]),

    utils.table('Slow requests in last 24 hours', [
      query('topk(10, avg((rate(ruby_http_request_duration_seconds_sum[1d]) / rate(ruby_http_request_duration_seconds_count[1d]))) by (controller, path))')
      + g.query.prometheus.withInstant(true)
      + g.query.prometheus.withFormat('table'), [cite: 19]
    ]),

    utils.table('Slow requests in selected range', [
      query('topk(10, avg((rate(ruby_http_request_duration_seconds_sum[$__range]) / rate(ruby_http_request_duration_seconds_count[$__range]))) by (controller, path))')
      + g.query.prometheus.withInstant(true)
      + g.query.prometheus.withFormat('table'), [cite: 19, 20]
    ]),

    utils.table('Most frequent actions in selected range', [
      query('topk(10, sum(rate(ruby_http_request_duration_seconds_count[$__range]) * 3600 * 24) by (controller, action))')
      + g.query.prometheus.withInstant(true)
      + g.query.prometheus.withFormat('table'), [cite: 20]
    ]),

    utils.table('Most frequent actions in last 24 hours', [
      query('topk(10, sum(rate(ruby_http_request_duration_seconds_count[1d]) * 3600 * 24) by (controller, action))')
      + g.query.prometheus.withInstant(true)
      + g.query.prometheus.withFormat('table'), [cite: 21]
    ]),
  ]);

/* -------------------------
   DASHBOARD
-------------------------- */
g.dashboard.new('Simple Server Dashboard')
+ g.dashboard.withUid('simple-server-dashboard')
+ g.dashboard.withDescription('Simple server dashboard')
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withVariables([utils.datasource]) 
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    pod,
    slos,
    load_balancer,
  ])
)