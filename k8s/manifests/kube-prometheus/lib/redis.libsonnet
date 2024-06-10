local common = (import 'common.libsonnet');
local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local redisMixin = addMixin({
  name: 'redis',
  dashboardFolder: 'Redis',
  mixin: (import 'redis-mixin/mixin.libsonnet'),
});

{
  grafanaDashboards: redisMixin.grafanaDashboards,
  prometheusRules: redisMixin.prometheusRules,
  exporterServices: [common.exporterService('redis', 9121, 'simple-v1')],
  serviceMonitors: [common.serviceMonitor('redis', 'simple-v1')],
}
