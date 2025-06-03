{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://prometheus-demo.dghs.gov.bd',
    retention: {
      enable: true,
      retention: '30d',
      storage: '10Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus-demo.dghs.gov.bd',
      port: 'web',
      path: '/',
    },
  },
  alertmanager: {
    externalUrl: 'http://alertmanager-demo.dghs.gov.bd',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager-demo.dghs.gov.bd',
      port: 'web',
      path: '/',
    },
  },
  postgresNamespaces: ['simple-v1'],
}
