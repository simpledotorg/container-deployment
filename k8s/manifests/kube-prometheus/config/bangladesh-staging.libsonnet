{
  grafana: {
    externalUrl: 'https://grafana-demo.bd.simple.org/',
    ingress: {
      name: 'grafana',
      host: 'grafana-demo.bd.simple.org',
      port: 'http',
    },
  },
  prometheus: {
    externalUrl: 'https://prometheus-demo.bd.simple.org',
    retention: '30d',
    storage: '10Gi',
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
}