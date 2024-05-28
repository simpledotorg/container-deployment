local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
  row(title, panels):
    g.panel.row.new(title)
    + g.panel.row.withPanels(panels),

  timeSeries(title, queries):
    g.panel.timeSeries.new(title)
    + g.panel.timeSeries.queryOptions.withTargets(queries),

  stat(title, queries):
    g.panel.stat.new(title)
    + g.panel.stat.queryOptions.withTargets(queries)
    + g.panel.stat.options.withJustifyMode('center'),

  stateTimeline(title, queries, thresholds):
    g.panel.stateTimeline.new(title)
    + g.panel.stateTimeline.queryOptions.withTargets(queries)
    + g.panel.stateTimeline.standardOptions.thresholds.withMode('absolute')
    + g.panel.stateTimeline.standardOptions.thresholds.withSteps(thresholds),

  barGauge(title, queries):
    g.panel.barGauge.new(title)
    + g.panel.barGauge.queryOptions.withTargets(queries),

  table(title, queries):
    g.panel.table.new(title)
    + g.panel.table.queryOptions.withTargets(queries),

  query(query, label=null):
    if label == null then
      g.query.prometheus.new('${datasource}', query)
    else
      g.query.prometheus.new('${datasource}', query)
      + g.query.prometheus.withLegendFormat(label),

  datasource:
    g.dashboard.variable.datasource.new('datasource', 'prometheus'),

}
