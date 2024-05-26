local common = (import 'common.libsonnet');
local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local grafanaDashboards = { grafanaDashboards: {
  'simple-server.json': (import 'simple-server/server-dashboard.libsonnet'),
} };

local prometheusRules = (import 'simple-server/prometheus-rules.libsonnet');

local simpleServerMixin = addMixin({
  name: 'simple-server',
  dashboardFolder: 'Simple Server',
  mixin: prometheusRules + grafanaDashboards,
});

{
  grafanaDashboards: simpleServerMixin.grafanaDashboards,
  prometheusRules: simpleServerMixin.prometheusRules,
  exporterService: common.exporterService('simple-server', 9394, 'simple-v1'),
  serviceMonitor: common.serviceMonitor('simple-server', 'simple-v1'),
}
