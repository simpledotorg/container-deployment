local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local replaceClusterString = function(content)
  std.parseJson(
    std.strReplace(std.toString(content), 'cluster=~"$cluster",', '') // Convert to string, replace, and parse back to JSON
  );

local grafanaDashboards = { grafanaDashboards: {
  'loki-logs.json': (import 'loki/dashboards/loki-logs.json'),
  'loki-chunks.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-chunks.json'),
  'loki-bloom-compactor.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-bloom-compactor.json'),
  'loki-bloom-gateway.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-bloom-gateway.json'),
  'loki-deletion.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-deletion.json'),
  'loki-mixin-recording-rules.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-mixin-recording-rules.json'),
  'loki-operational.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-operational.json'),
  'loki-reads-resources.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-reads.json'),
  'loki-resources-overview.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-resources-overview.json'),
  'loki-retention.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-retention.json'),
  'loki-writes-resources.json': replaceClusterString(import 'loki-mixin-compiled-ssd/dashboards/loki-writes.json'),
}};

local LokiMixin = addMixin({
  name: 'loki',
  dashboardFolder: 'Loki',
  mixin: grafanaDashboards,
});

{
  grafanaDashboards: LokiMixin.grafanaDashboards,
}
