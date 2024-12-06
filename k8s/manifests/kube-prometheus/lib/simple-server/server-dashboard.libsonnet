local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local utils = (import './dashboard-utils.libsonnet');
local query = utils.query;


local slos =
  g.panel.row.new('SLOs')
  + g.panel.row.withPanels([
    utils.stateTimeline(
      'P95 Response Time < 1.2s',
      [
        query('simple:response_time:p95:total', 'All'),
        query('simple:response_time:p95:api', 'API'),
        query('simple:response_time:p95:dashboard', 'Dashboard'),
      ],
      [{ color: 'green', value: null }, { color: 'red', value: 1.2 }]
    ) + g.panel.stateTimeline.panelOptions.withGridPos(w='24'),
    utils.stat('Healthy hosts', [
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
  utils.row('Load Balancer', [
    utils.timeSeries('Request Rate', [
      query('sum(rate(ruby_http_request_duration_seconds_count[$__rate_interval])) > 0', 'All'),
      query('sum(rate(ruby_http_request_duration_seconds_count{controller=~"api/.+"}[$__rate_interval])) > 0', 'API'),
      query('sum(rate(ruby_http_request_duration_seconds_count{controller!~"api/.+"}[$__rate_interval])) > 0', 'Dashboard'),
    ])
    + g.panel.timeSeries.fieldConfig.defaults.custom.withAxisLabel('Req/sec')
    + g.panel.timeSeries.standardOptions.withUnit('reqps')
    + g.panel.timeSeries.options.legend.withIsVisible(false),
    utils.timeSeries('Non 2xx', [
      query('sum by(status) (rate(ruby_http_requests_total{status!~"2.."}[$__rate_interval])) > 0', 'All'),
      query('sum by(status) (rate(ruby_http_requests_total{status!~"2..",controller=~"api/.+"}[$__rate_interval])) > 0', 'API'),
      query('sum by(status) (rate(ruby_http_requests_total{status!~"2..",controller!~"api/.+"}[$__rate_interval])) > 0', 'Dashboard'),
    ]),
    utils.timeSeries('Response Time', [
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
    ])
    + g.panel.timeSeries.standardOptions.withUnit('s'),
    utils.barGauge('Nginx Connections', [
      query(
        |||
          sum by(state) (nginx_ingress_controller_nginx_process_connections)
        |||, '{{state}}'
      ),
    ]),
    utils.table('Slow actions in selected range', [
      query(
        |||
          topk(10, avg(
           (rate(ruby_http_request_duration_seconds_sum[$__range]) / 
            rate(ruby_http_request_duration_seconds_count[$__range]))) 
          by (controller, action)) 
        |||
      ) +
      g.query.prometheus.withInstant(true) +
      g.query.prometheus.withFormat('table'),
    ]),
    utils.table('Slow actions in last 24 hours', [
      query(
        |||
          topk(10, avg(
           (rate(ruby_http_request_duration_seconds_sum[1d]) / 
            rate(ruby_http_request_duration_seconds_count[1d]))) 
          by (controller, action)) 
        |||
      ) +
      g.query.prometheus.withInstant(true) +
      g.query.prometheus.withFormat('table'),
    ]),
    utils.table('Slow requests in last 24 hours', [
      query(
        |||
          topk(10, avg(
           (rate(ruby_http_request_duration_seconds_sum[1d]) /
            rate(ruby_http_request_duration_seconds_count[1d])))
          by (controller, path))
        |||
      ) +
      g.query.prometheus.withInstant(true) +
      g.query.prometheus.withFormat('table'),
    ]),
    utils.table('Slow requests in selected range', [
      query(
        |||
          topk(10, avg(
           (rate(ruby_http_request_duration_seconds_sum[$__range]) /
            rate(ruby_http_request_duration_seconds_count[$__range])))
          by (controller, path))
        |||
      ) +
      g.query.prometheus.withInstant(true) +
      g.query.prometheus.withFormat('table'),
    ]),
    utils.table('Most frequent actions in selected range', [
      query(
        |||
          topk(10, 
            sum(
              rate(ruby_http_request_duration_seconds_count[$__range]) * 3600 * 24) 
            by (controller, action))
        |||,
      ) +
      g.query.prometheus.withInstant(true) +
      g.query.prometheus.withFormat('table'),
    ]),
    utils.table('Most frequent actions in last 24 hours', [
      query(
        |||
          topk(10, 
            sum(
              rate(ruby_http_request_duration_seconds_count[1d]) * 3600 * 24) 
            by (controller, action))
        |||
      ) + g.query.prometheus.withInstant(true)
      + g.query.prometheus.withFormat('table'),
    ]),
  ]);

g.dashboard.new('Simple Server Dashboard')
+ g.dashboard.withUid('simple-server-dashboard')
+ g.dashboard.withDescription('Simple server dashboard')
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withVariables([utils.datasource])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    slos,
    load_balancer,
    // sync_to_user,
    // sync_from_user,
    // database,
  ])
)
