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
            {
              datasource: {
                type: 'prometheus',
                uid: '${datasource}',
              },
              definition: 'label_values(pg_up,namespace)',
              hide: 0,
              includeAll: false,
              label: 'namespace',
              multi: false,
              name: 'namespace',
              options: [],
              query: {
                qryType: 1,
                query: 'label_values(pg_up,namespace)',
                refId: 'PrometheusVariableQueryEditor-VariableQuery',
              },
              refresh: 1,
              regex: '',
              skipUrlSync: false,
              sort: 0,
              type: 'query',
            }
            {
              allValue: '.+',
              datasource: {
                uid: '$datasource',
              },
              definition: 'label_values(pg_stat_database_tup_fetched{instance=~"$instance", datname!~"template.*|postgres", namespace=~"$namespace"},datname)',
              hide: 0,
              includeAll: true,
              label: 'db',
              multi: false,
              name: 'db',
              options: [],
              query: {
                qryType: 1,
                query: 'label_values(pg_stat_database_tup_fetched{instance=~"$instance", datname!~"template.*|postgres", namespace=~"$namespace"},datname)',
                refId: 'PrometheusVariableQueryEditor-VariableQuery',
              },
              refresh: 1,
              regex: '',
              skipUrlSync: false,
              sort: 0,
              tagValuesQuery: '',
              tagsQuery: '',
              type: 'query',
              useTags: false,
            },
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
