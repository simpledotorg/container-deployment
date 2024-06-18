local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local common = (import 'common.libsonnet');
local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local postgresMixin = addMixin({
  name: 'postgres',
  dashboardFolder: 'Postgres',
  mixin: (import 'postgres_mixin/mixin.libsonnet'),
});


{
  grafanaDashboards: postgresMixin.grafanaDashboards {
    Postgres+: {
      'postgres-overview.json'+: {
        templating+: {
          list+: [
            g.dashboard.variable.query.new('namespace', 'label_values(pg_up,namespace)'),
          ],
        },
      },
    },
  },
  prometheusRules: postgresMixin.prometheusRules,
  monitors(namespaces): {
    exporterServices: [
      common.exporterService('postgres', 9187, ns)
      for ns in namespaces
    ],
    serviceMonitors: [
      common.serviceMonitor('postgres', ns)
      for ns in namespaces
    ],
  },
}
