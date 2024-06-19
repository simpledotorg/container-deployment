{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://prometheus-demo.bd.simple.org',
    retention: {
      enable: true,
      retention: '30d',
      storage: '10Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus-demo.bd.simple.org',
      port: 'web',
    },
  },
  alertmanager: {
    externalUrl: 'http://alertmanager-demo.bd.simple.org',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager-demo.bd.simple.org',
      port: 'web',
    },
  },
  postgresNamespaces: ['simple-v1'],
}
