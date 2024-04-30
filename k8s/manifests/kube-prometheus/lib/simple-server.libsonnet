local common = (import 'common.libsonnet');

{
  grafanaDashboards: [],
  prometheusRules: [],
  exporterService: common.exporterService('simple-server', 9394, 'simple-v1'),
  serviceMonitor: common.serviceMonitor('simple-server', 'simple-v1'),
}
