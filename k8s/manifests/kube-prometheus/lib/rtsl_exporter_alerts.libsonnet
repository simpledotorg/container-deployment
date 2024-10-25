

local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local prometheusRules = {
  prometheusRules+:: {
    groups+: [
      {
        name: 'rtsl_exporter.rules',
        rules: [
          {
            alert: 'RtslExporterDown',
            expr: |||
              up{job="rtsl-exporter", namespace="rtsl-exporter", service="rtsl-exporter"} == 0
            |||,
            'for': '5m',
            labels: {
              severity: 'critical'
            },
            annotations: {
              summary: "RTSL Exporter service is down",
              description: "The RTSL Exporter service is not reachable."
            }
          }
        ],
      },
    ],
  },
};

local grafanaDashboards = {};

local rtslExporterMixin = addMixin({
  name: 'rtsl_exporter',
  dashboardFolder: 'RTSL Exporter',
  mixin: prometheusRules + grafanaDashboards,
});

{
  grafanaDashboards: rtslExporterMixin.grafanaDashboards,
  prometheusRules: rtslExporterMixin.prometheusRules,
}