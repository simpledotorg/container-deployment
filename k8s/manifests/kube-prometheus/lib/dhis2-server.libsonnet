local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local grafanaDashboards = { grafanaDashboards: {
  'dhis2-springboot.json': (import 'dhis2-server/springboot-dashboard.json'),
  'dhis2-tomcat.json': (import 'dhis2-server/tomcat-dashboard.json'),
  'dhis2-artemis.json': (import 'dhis2-server/artemis-dashboard.json'),
} };


local DHIS2Mixin = addMixin({
  name: 'dhis2-server',
  dashboardFolder: 'DHIS2 Server',
  mixin: grafanaDashboards,
});

{
  grafanaDashboards: DHIS2Mixin.grafanaDashboards,
}
