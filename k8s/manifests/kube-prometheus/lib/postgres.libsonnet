local common = (import 'common.libsonnet');
local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local postgresMixin = addMixin({
  name: 'postgres',
  dashboardFolder: 'Postgres',
  mixin: (import 'postgres_mixin/mixin.libsonnet'),
});

{
  grafanaDashboards: postgresMixin.grafanaDashboards,
  prometheusRules: postgresMixin.prometheusRules,
  monitors(namespaces): {
    exporterServices: [
      common.exporterService('postgres', 9187, ns) for ns in namespaces
    ],
    serviceMonitors: [
      common.serviceMonitor('postgres', ns) for ns in namespaces
    ],
  }
}