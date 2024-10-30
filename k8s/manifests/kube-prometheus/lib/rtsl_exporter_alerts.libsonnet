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
              absent_over_time(up{job="rtsl-exporter", namespace="rtsl-exporter", service="rtsl-exporter"}[1m])
            |||,
            'for': '1m',
            labels: {
              severity: 'critical'
            },
            annotations: {
              summary: "RTSL Exporter service down",
              description: "No metrics have been received from the RTSL Exporter service for the past 1 minute."
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