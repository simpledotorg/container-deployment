local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local grafanaDashboards = { grafanaDashboards: {
  'dhis2-springboot.json': (import 'dhis2-server/springboot-dashboard.libsonnet'),
  'dhis2-tomcat.json': (import 'dhis2-server/tomcat-dashboard.libsonnet'),
  'dhis2-artemis.json': (import 'dhis2-server/artemis-dashboard.libsonnet'),
} };


local DHIS2Mixin = addMixin({
  name: 'dhis2-server',
  dashboardFolder: 'DHIS2 Server',
  mixin: grafanaDashboards,
});

{
  grafanaDashboards: DHIS2Mixin.grafanaDashboards,
}
