{
  grafana: {
    enable: true,
    enableDhis2Dashboards: true,
    externalUrl: 'https://grafana-sandbox.simple.org/',
    ingress: {
      name: 'grafana',
      host: 'grafana-sandbox.simple.org',
      port: 'http',
      path: '/',
    },
  },
  prometheus: {
    externalUrl: 'https://prometheus-sandbox.simple.org',
    retention: {
      enable: true,
      retention: '30d',
      storage: '70Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus-sandbox.simple.org',
      port: 'web',
      path: '/',
    },
  },
  alertmanager: {
    externalUrl: 'http://alertmanager-sandbox.simple.org',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager-sandbox.simple.org',
      port: 'web',
      path: '/',
    },
  },
  blackboxProbes: [
    {
      name: 'simple-server-sandbox',
      targets: ['https://api-sandbox.simple.org/'],
      labels: {
        service: 'simple_server',
        environment: 'sandbox',
        country: 'ind',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-dashboard-sandbox',
      targets: ['https://dashboard-sandbox.simple.org/'],
      labels: {
        service: 'simple_dashboard',
        environment: 'sandbox',
        country: 'ind',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-metabase-sandbox',
      targets: ['https://metabase-sandbox.simple.org/'],
      labels: {
        service: 'metabase',
        environment: 'sandbox',
        country: 'ind',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-argocd-sandbox',
      targets: ['https://argocd-sandbox.simple.org/'],
      labels: {
        service: 'argocd',
        environment: 'sandbox',
        country: 'ind',
      },
      module: 'http_2xx',
    },
  ],
  postgresNamespaces: ['simple-v1', 'dhis2-demo-ecuador', 'dhis2-sandbox-01', 'dhis2-sandbox-epidemics'],
}
