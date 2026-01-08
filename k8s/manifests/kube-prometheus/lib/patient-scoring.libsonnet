local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local prometheusRules = {
  prometheusRules+:: {
    groups+: [
      {
        name: 'patient-scoring.rules',
        rules: [
          {
            alert: 'PatientScoringBatchFailed',
            expr: |||
              simple_scoring_batch_last_run_status == 0
            |||,
            'for': '5m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'Patient scoring batch job failed',
              description: 'The patient scoring batch job for score "{{ $labels.score }}" has failed. Last run status: {{ $value }}',
            },
          },
          {
            alert: 'PatientScoringBatchStale',
            expr: |||
              (time() - simple_scoring_batch_last_run_date) > (16 * 24 * 60 * 60)
            |||,
            'for': '1h',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Patient scoring batch job is stale',
              description: 'The patient scoring batch job for score "{{ $labels.score }}" has not run in over 16 days. The job is scheduled to run every 15 days.',
            },
          },
          {
            alert: 'PatientScoringBatchNoData',
            expr: 'absent(simple_scoring_batch_last_run_status)',
            'for': '24h',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Patient scoring batch metrics missing',
              description: 'No patient scoring batch metrics have been received. The scoring job may not be running or metrics are not being pushed.',
            },
          },
        ],
      },
    ],
  },
};

local patientScoringMixin = addMixin({
  name: 'patient-scoring',
  dashboardFolder: 'Simple Server',
  mixin: prometheusRules,
});

{
  prometheusRules: patientScoringMixin.prometheusRules,
}
