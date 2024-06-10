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
  exporterServices: [
    common.exporterService('postgres', 9187, 'simple-v1'),
    common.exporterService('postgres', 9187, 'dhis2-demo-ecuador')
  ],
  serviceMonitors: [
    common.serviceMonitor('postgres', 'simple-v1'),
    common.serviceMonitor('postgres', 'dhis2-demo-ecuador')
  ],
}