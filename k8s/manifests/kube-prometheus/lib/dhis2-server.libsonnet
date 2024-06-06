local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local grafanaDashboards = { grafanaDashboards: {
  'dhis2-server.json': (import 'dhis2-server/server-dashboard.libsonnet'),
} };


local DHIS2Mixin = addMixin({
  name: 'dhis2-server',
  dashboardFolder: 'DHIS2 Server',
});

{
  grafanaDashboards: DHIS2Mixin.grafanaDashboards,
}
