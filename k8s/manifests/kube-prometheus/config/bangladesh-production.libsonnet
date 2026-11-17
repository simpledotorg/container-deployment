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
  blackboxProbes: [
    {
      name: 'simple-server-bgd',
      targets: ['https://api.bd.simple.org/'],
      labels: {
        service: 'simple_server',
        environment: 'prod',
        country: 'bgd',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-dashboard-bgd',
      targets: ['https://dashboard.bd.simple.org/'],
      labels: {
        service: 'simple_dashboard',
        environment: 'prod',
        country: 'bgd',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-metabase-bgd',
      targets: ['https://metabase.bd.simple.org/'],
      labels: {
        service: 'metabase',
        environment: 'prod',
        country: 'bgd',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-argocd-bgd',
      targets: ['https://argocd.bd.simple.org/'],
      labels: {
        service: 'argocd',
        environment: 'prod',
        country: 'bgd',
      },
      module: 'http_2xx',
    },
  ],
  postgresNamespaces: ['simple-v1'],
}
