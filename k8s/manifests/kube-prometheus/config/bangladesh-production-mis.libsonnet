{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://prometheus.ncdbd.dghs.gov.bd',
    retention: {
      enable: true,
      retention: '14d',
      storage: '30Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus.ncdbd.dghs.gov.bd',
      port: 'web',
      path: '/',
    },
  },
  alertmanager: {
    // DGHS uses `alerts`, not `alertmanager`, for this hostname.
    externalUrl: 'http://alerts.ncdbd.dghs.gov.bd',
    ingress: {
      name: 'alertmanager-main',
      host: 'alerts.ncdbd.dghs.gov.bd',
      port: 'web',
      path: '/',
    },
  },
  blackboxProbes: [
    {
      name: 'simple-server-bgd-mis',
      targets: ['https://api.ncdbd.dghs.gov.bd/'],
      labels: {
        service: 'simple_server',
        environment: 'prod',
        country: 'bgd',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-dashboard-bgd-mis',
      targets: ['https://dashboard.ncdbd.dghs.gov.bd/'],
      labels: {
        service: 'simple_dashboard',
        environment: 'prod',
        country: 'bgd',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-metabase-bgd-mis',
      targets: ['https://analytics.ncdbd.dghs.gov.bd/'],
      labels: {
        service: 'metabase',
        environment: 'prod',
        country: 'bgd',
      },
      module: 'http_2xx',
    },
    {
      name: 'simple-argocd-bgd-mis',
      targets: ['https://argocd.ncdbd.dghs.gov.bd/'],
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
