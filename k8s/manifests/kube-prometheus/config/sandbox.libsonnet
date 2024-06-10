{
  grafana: {
    enable: true,
    enableDhis2Dashboards: true,
    externalUrl: 'https://grafana-sandbox.simple.org/',
    ingress: {
      name: 'grafana',
      host: 'grafana-sandbox.simple.org',
      port: 'http',
    },
  },
  prometheus: {
    externalUrl: 'https://prometheus-sandbox.simple.org',
    retention: '7d',
    storage: '10Gi',
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus-sandbox.simple.org',
      port: 'web',
    },
  },
  alertmanager: {
    externalUrl: 'http://alertmanager-sandbox.simple.org',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager-sandbox.simple.org',
      port: 'web',
    },
  },
}
