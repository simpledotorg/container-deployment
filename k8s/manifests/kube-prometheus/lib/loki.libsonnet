local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local grafanaDashboards = { grafanaDashboards: {
  'loki-logs.json': (import 'loki/dashboards/loki-logs.json'),
  'loki-chunks.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-chunks.json'),
  'loki-bloom-compactor.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-bloom-compactor.json'),
  'loki-bloom-gateway.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-bloom-gateway.json'),
  'loki-deletion.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-deletion.json'),
  'loki-mixin-recording-rules.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-mixin-recording-rules.json'),
  'loki-operational.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-operational.json'),
  'loki-reads.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-reads.json'),
  'loki-resources-overview.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-resources-overview.json'),
  'loki-retention.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-retention.json'),
  'loki-writes.json': (import 'loki-mixin-compiled-ssd/dashboards/loki-writes.json'),
}};

local LokiMixin = addMixin({
  name: 'loki',
  dashboardFolder: 'Loki',
  mixin: grafanaDashboards,
});

{
  grafanaDashboards: LokiMixin.grafanaDashboards,
}
