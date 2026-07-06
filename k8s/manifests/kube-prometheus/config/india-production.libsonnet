{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://prometheus.in.simple.org',
    retention: {
      enable: true,
      retention: '14d',
      storage: '50Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus.in.simple.org',
      port: 'web',
      path: '/',
    },
  },
  alertmanager: {
    externalUrl: 'http://alertmanager.in.simple.org',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager.in.simple.org',
      port: 'web',
      path: '/',
    },
  },
  blackboxProbes: [
    {
      name: 'simple-server-ind',
      targets: ['https://api.simple.org/'],
      labels: {
        service: 'simple_server',
        environment: 'prod',
        country: 'ind',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-dashboard-ind',
      targets: ['https://dashboard.simple.org/'],
      labels: {
        service: 'simple_dashboard',
        environment: 'prod',
        country: 'ind',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-metabase-ind',
      targets: ['https://metabase.simple.org/'],
      labels: {
        service: 'metabase',
        environment: 'prod',
        country: 'ind',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-argocd-ind',
      targets: ['https://argocd.simple.org/'],
      labels: {
        service: 'argocd',
        environment: 'prod',
        country: 'ind',
      },
      module: 'http_2xx',
    },
  ],
  postgresNamespaces: ['simple-v1'],
}
