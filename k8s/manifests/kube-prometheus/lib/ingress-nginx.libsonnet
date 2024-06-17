local common = (import 'common.libsonnet');
local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local ingressNginxMixin = addMixin({
  name: 'ingress-nginx',
  dashboardFolder: 'Ingress Nginx',
  mixin: (import 'ingress-nginx-mixin/mixin.libsonnet'),
});

{
  grafanaDashboards: ingressNginxMixin.grafanaDashboards,
  prometheusRules: ingressNginxMixin.prometheusRules,
  exporterServices: common.exporterService('ingress-nginx', 10254, 'ingress-nginx'),
  serviceMonitors: common.serviceMonitor('ingress-nginx', 'ingress-nginx'),
}
