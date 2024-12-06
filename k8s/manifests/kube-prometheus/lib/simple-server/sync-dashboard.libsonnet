local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local utils = (import './dashboard-utils.libsonnet');
local query = utils.query;

local sync_to_user =
  utils.row('Sync To User', [
    utils.timeSeries(
      'Request Rate', [query(
        |||
          sum by(controller) (rate(ruby_http_requests_total{action="sync_to_user"}[$__rate_interval]))
        |||
      )],
    ),
    utils.timeSeries('Latency', [
      query(
        |||
          sum by(controller) (rate(ruby_http_request_duration_seconds_sum{action="sync_to_user"}[$__rate_interval]))
        |||
      ),
    ]) + g.panel.timeSeries.standardOptions.withUnit('s'),
    utils.timeSeries('Error Rate', [
      query(
        |||
          sum by(status) (rate(ruby_http_requests_total{action="sync_to_user", status!~"2.."}[$__rate_interval]))
        |||
      ),
    ]),
  ]);

local sync_from_user =
  utils.row('Sync From User', [
    utils.timeSeries(
      'Request Rate', [query(
        |||
          sum by(controller) (rate(ruby_http_requests_total{action="sync_from_user"}[$__rate_interval]))
        |||
      )],
    ),
    utils.timeSeries('Latency', [
      query(
        |||
          sum by(controller) (rate(ruby_http_request_duration_seconds_sum{action="sync_from_user"}[$__rate_interval]))
        |||
      ),
    ]) + g.panel.timeSeries.standardOptions.withUnit('s'),
    utils.timeSeries('Error Rate', [
      query(
        |||
          sum by(status) (rate(ruby_http_requests_total{action="sync_from_user", status!~"2.."}[$__rate_interval]))
        |||
      ),
    ]),
  ]);

g.dashboard.new('Simple Sync Dashboard')
+ g.dashboard.withUid('simple-sync-dashboard')
+ g.dashboard.withDescription('Simple sync dashboard')
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withVariables([utils.datasource])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([sync_to_user, sync_from_user])
)
