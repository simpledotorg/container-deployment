local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local utils = (import './dashboard-utils.libsonnet');
local query = utils.query;

local refreshes =
      utils.timeSeries('MatView Refresh Duration', [
        query('ruby_reporting_views_refresh_duration_seconds', 'view!="all"'),
      ])
      + g.panel.timeSeries.fieldConfig.defaults.custom.withAxisLabel('seconds')
      + g.panel.timeSeries.options.legend.withIsVisible(false);

g.dashboard.new('MatView Refresh Dashboard')
+ g.dashboard.withUid('matview-refresh-dashboard')
+ g.dashboard.withDescription('Matview Refresh durations')
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withVariables([utils.datasource])
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    refreshes,
  ])
)
