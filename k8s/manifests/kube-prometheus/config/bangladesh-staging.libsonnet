{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://prometheus-demo-simpleapp.dghs.gov.bd',
    retention: {
      enable: true,
      retention: '30d',
      storage: '10Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus-demo-simpleapp.dghs.gov.bd',
      port: 'web',
      path: '/',
    },
  },
  alertmanager: {
    externalUrl: 'http://alertmanager-demo-simpleapp.dghs.gov.bd',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager-demo-simpleapp.dghs.gov.bd',
      port: 'web',
      path: '/',
    },
  },
  postgresNamespaces: ['simple-v1'],
}
