{
  local prometheusLabel = function(name) {
    'prometheus.io/app': name,
  },

  prometheusLabel: prometheusLabel,

  exporterService: function(name, port, namespace) {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: name + '-exporter',
      namespace: namespace,
      labels: prometheusLabel(name),
    },
    spec: {
      selector: prometheusLabel(name),
      ports: [{ name: 'metrics', port: port }],
    },
  },

  serviceMonitor: function(name, namespace) {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'ServiceMonitor',
    metadata: {
      name: name + '-service-monitor',
      namespace: namespace,
      labels: prometheusLabel(name),
    },
    spec: {
      jobLabel: name,
      endpoints: [{ port: 'metrics' }],
      selector: {
        matchLabels: prometheusLabel(name),
      },
    },
  },
}
