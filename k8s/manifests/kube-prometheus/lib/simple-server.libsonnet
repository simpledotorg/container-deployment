local common = (import 'common.libsonnet');

local grafanaDashboards = {
  'Simple Server': {
    'rails-performance.json': (import 'dashboards/rails-performance.json'),
    'simple-server.json': (import 'dashboards/simple-server.libsonnet'),
  },
};

{
  grafanaDashboards: grafanaDashboards,
  prometheusRules: [],
  exporterService: common.exporterService('simple-server', 9394, 'simple-v1'),
  serviceMonitor: common.serviceMonitor('simple-server', 'simple-v1'),
}
