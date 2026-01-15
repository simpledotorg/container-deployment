{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://prometheus.in.simple.org',
    retention: {
      enable: true,
      retention: '14d',
      storage: '50Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus.in.simple.org',
      port: 'web',
      path: '/',
    },
  },
  alertmanager: {
    externalUrl: 'http://alertmanager.in.simple.org',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager.in.simple.org',
      port: 'web',
      path: '/',
    },
  },
  postgresNamespaces: ['simple-v1'],
}
