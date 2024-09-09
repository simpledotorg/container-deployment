{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://prometheus.bd.simple.org',
    retention: {
      enable: true,
      retention: '14d',
      storage: '30Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus.bd.simple.org',
      port: 'web',
      path: '/',
    },
  },
  alertmanager: {
    externalUrl: 'http://alertmanager.bd.simple.org',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager.bd.simple.org',
      port: 'web',
      path: '/',
    },
  },
  postgresNamespaces: ['simple-v1'],
}
