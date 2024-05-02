local common = (import 'common.libsonnet');

local grafanaDashboards = {
  'Simple Server': {
    'rails-metrics.json': (import '../dashboards/rails-metrics.json'),
  },
};

{
  grafanaDashboards: grafanaDashboards,
  prometheusRules: [],
  exporterService: common.exporterService('simple-server', 9394, 'simple-v1'),
  serviceMonitor: common.serviceMonitor('simple-server', 'simple-v1'),
}
