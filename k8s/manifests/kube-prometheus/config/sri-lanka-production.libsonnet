{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://simples13.health.gov.lk',  // SSL not required
    retention: {
      enable: false,
      retention: '1y',
      storage: '30Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'simples13.health.gov.lk',
      port: 'web',
      path: '/prometheus',  // Handle path
    },
    // Add affintiy
  },
  alertmanager: {
    externalUrl: 'http://simples13.health.gov.lk',  // SSL not required
    ingress: {
      name: 'alertmanager-main',
      host: 'simples13.health.gov.lk',
      port: 'web',
      path: '/alertmanager',  // Handle path
    },
  },
  postgresNamespaces: ['simple-v1'],
  sslEnabled: false,
}
