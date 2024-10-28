

local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local prometheusRules = {
  prometheusRules+:: {
    groups+: [
      {
        name: 'rtsl-exporter.rules',
        rules: [
          {
            alert: 'RtslExporterDown',
            expr: |||
              up{job="rtsl-exporter", namespace="rtsl-exporter", service="rtsl-exporter"} == 0
            |||,
            'for': '3s',
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

local rtslExporterMixin = addMixin({
  name: 'rtsl-exporter',
  dashboardFolder: 'RTSL Exporter',
  mixin: prometheusRules
});

{
  prometheusRules: rtslExporterMixin.prometheusRules
}