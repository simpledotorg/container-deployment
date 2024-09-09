{
  grafana: {
    enable: true,
    enableDhis2Dashboards: true,
    externalUrl: 'https://grafana.simple.org/',
    ingress: {
      name: 'grafana',
      host: 'grafana.simple.org',
      port: 'http',
      path: '/',
    },
  },
  prometheus: {
    externalUrl: 'https://prometheus.simple.org',
    retention: {
      enable: true,
      retention: '30d',
      storage: '10Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus.simple.org',
      port: 'web',
      path: '/',
    },
  },
  alertmanager: {
    externalUrl: 'http://alertmanager.simple.org',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager.simple.org',
      port: 'web',
      path: '/',
    },
  },
  postgresNamespaces: [],
}
