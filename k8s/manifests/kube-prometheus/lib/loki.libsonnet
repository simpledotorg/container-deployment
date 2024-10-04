local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

// Fix cluster label issue: https://github.com/grafana/loki/issues/9273
local replaceClusterString = function(content)
  std.parseJson(
    std.strReplace(std.toString(content), 'cluster=~\\\"$cluster\\\",', '')
  );

local grafanaDashboards = { grafanaDashboards: {
  'loki-logs.json': (import 'loki/dashboards/loki-logs.json'),
  'loki-chunks.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-chunks.json'),
  'loki-deletion.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-deletion.json'),
  'loki-operational.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-operational.json'),
  'loki-reads.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-reads.json'),
  'loki-resources-overview.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-resources-overview.json'),
  'loki-retention.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-retention.json'),
  'loki-writes.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-writes.json'),
  
  // https://grafana.com/grafana/dashboards/17781-loki-metrics-dashboard
  'loki-overview.json': (import 'loki/dashboards/17781_rev1.json'),
}};

local LokiMixin = addMixin({
  name: 'loki',
  dashboardFolder: 'Loki',
  mixin: grafanaDashboards,
});

{
  grafanaDashboards: LokiMixin.grafanaDashboards,
}
