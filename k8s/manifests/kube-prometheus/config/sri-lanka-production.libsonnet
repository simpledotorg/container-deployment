{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://simples13.health.gov.lk/prometheus',
    retention: {
      enable: true,
      retention: '30d',
      storage: '10Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'simples13.health.gov.lk',
      port: 'web',
      path: '/prometheus(/|$)(.*)',
    },
    affinity: {
      nodeAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: {
          nodeSelectorTerms: [
            {
              matchExpressions: [
                {
                  key: 'role-prometheus',
                  operator: 'In',
                  values: ['true'],
                },
              ],
            },
          ],
        },
      },
    },
  },
  alertmanager: {
    externalUrl: 'https://simples13.health.gov.lk/alertmanager',
    ingress: {
      name: 'alertmanager-main',
      host: 'simples13.health.gov.lk',
      port: 'web',
      path: '/alertmanager(/|$)(.*)',
    },
  },
  blackboxProbes: [
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
    {
      name: 'simple-dashboard-lka',
      targets: ['https://dashboard-simple.health.gov.lk/'],
      labels: {
        service: 'simple_dashboard',
        environment: 'prod',
        country: 'lka',
      },
      module: 'http_2xx',
    },
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
  ],
  postgresNamespaces: ['simple-v1'],
  sslEnabled: false,
}
