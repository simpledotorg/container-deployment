local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Simple Server Dasboard')
+ g.dashboard.withUid('simple-server-dashboard')
+ g.dashboard.withDescription('Simple server dashboard')
+ g.dashboard.withPanels(
  g.util.grid.makeGrid([
    g.panel.row.new('SLOs')
    + g.panel.row.withPanels([
      g.panel.timeSeries.new('SLO: APIs are < 300ms at p95'),
      g.panel.timeSeries.new('SLO: Dashboard p95 latency is under 1.2 seconds'),
    ]),
    g.panel.row.new('Load Balancer')
    + g.panel.row.withPanels([
      g.panel.timeSeries.new('Request Rate'),
      g.panel.timeSeries.new('Non 2xx'),
    ]),
    g.panel.row.new('Sync To User')
    + g.panel.row.withPanels([
      g.panel.timeSeries.new('Request Rate'),
      g.panel.timeSeries.new('Non 2xx'),
    ]),
    g.panel.row.new('Sync From User')
    + g.panel.row.withPanels([
      g.panel.timeSeries.new('Request Rate'),
      g.panel.timeSeries.new('Non 2xx'),
    ]),
    g.panel.row.new('Databases')
    + g.panel.row.withPanels([
      g.panel.timeSeries.new('Request Rate'),
      g.panel.timeSeries.new('Non 2xx'),
    ]),

  ])
)
