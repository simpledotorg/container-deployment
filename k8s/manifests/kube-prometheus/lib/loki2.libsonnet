local common = (import 'common.libsonnet');
local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local loki2Mixin = addMixin({
  name: 'loki2',
  dashboardFolder: 'Loki2',
  mixin: (import 'loki-mixin/mixin-ssd.libsonnet'),
});

{
  grafanaDashboards: loki2Mixin.grafanaDashboards,
  prometheusRules: loki2Mixin.prometheusRules,
}
