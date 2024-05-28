{
  grafana: {
    enable: true,
    externalUrl: 'http://localhost:9091',
    ingress: {
      name: 'grafana',
      host: 'localhost',
      port: 'http',
    },
  },
  prometheus: {
    externalUrl: 'http://localhost:9091',
    ingress: {
      name: 'prometheus-k8s',
      host: 'localhost',
      port: 'web',
    },
  },
  alertmanager: {
    externalUrl: 'http://localhost:9092',
    ingress: {
      name: 'alertmanager-main',
      host: 'localhost',
      port: 'web',
    },
  },
}
