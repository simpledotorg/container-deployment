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
    {
      name: 'simple-server-lka',
      targets: ['https://api-simple.health.gov.lk/'],
      labels: {
        service: 'simple_server',
        environment: 'prod',
        country: 'lka',
      },
      module: 'http_2xx',
    },
    // {
    //   name: 'simple-dashboard-lka',
    //   targets: ['https://dashboard.lk.simple.org/'],
    //   labels: {
    //     service: 'simple_dashboard',
    //     environment: 'prod',
    //     country: 'lka',
    //   },
    //   module: 'http_2xx',
    // },
    {
      name: 'simple-metabase-lka',
      targets: ['https://metabase-simple.health.gov.lk/'],
      labels: {
        service: 'metabase',
        environment: 'prod',
        country: 'lka',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-argocd-lka',
      targets: ['https://argocd-simple.health.gov.lk/'],
      labels: {
        service: 'argocd',
        environment: 'prod',
        country: 'lka',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-server-eth',
      targets: ['https://simple.moh.gov.et/'],
      labels: {
        service: 'argocd',
        environment: 'prod',
        country: 'eth',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-metabase-eth',
      targets: ['https://simple.moh.gov.et/'],
      labels: {
        service: 'metabase',
        environment: 'prod',
        country: 'eth',
      },
      module: 'http_2xx',
    },
  ],
  alertmanager: {
    externalUrl: 'http://alertmanager-sandbox.simple.org',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager-sandbox.simple.org',
      port: 'web',
      path: '/',
    },
  },
  postgresNamespaces: ['simple-v1', 'dhis2-demo-ecuador', 'dhis2-sandbox-01', 'dhis2-sandbox-epidemics'],
}
