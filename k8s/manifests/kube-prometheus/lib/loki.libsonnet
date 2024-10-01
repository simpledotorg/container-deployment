local common = (import 'common.libsonnet');
local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local lokiMixin = addMixin({
  name: 'loki',
  dashboardFolder: 'Loki',
  mixin: (import 'loki-mixin/mixin.libsonnet'),
});

{
  grafanaDashboards: lokiMixin.grafanaDashboards,
}
