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
      retention: '60d',  // Retention duration updated to 60 days
      storage: '10Gi',   // Storage size
    },
    extraScrapeConfigs: [
      {
        job_name: 'federate',
        scheme: 'https',
        scrape_interval: '15s',
        metrics_path: '/federate',
        params: {
          'match[]': ['{__name__=~".+"}'],
        },
        static_configs: [
          {
            targets: [
              'https://prometheus-sandbox.simple.org',
              'https://prometheus-demo.bd.simple.org',
              'https://prometheus.in.simple.org',
              'https://simples13.health.gov.lk/prometheus',
            ],
          },
        ],
        basic_auth: {
          username: 'db25a3474d90',
          password_file: '/etc/secrets/default',
        },
        relabel_configs: [
          {
            target_label: 'country',
            replacement: 'sandbox',
            source_labels: ['__param_target'],
            regex: 'https://prometheus-sandbox.simple.org',
          },
          {
            target_label: 'environment',
            replacement: 'sandbox',
            source_labels: ['__param_target'],
            regex: 'https://prometheus-sandbox.simple.org',
          },
          {
            target_label: 'country',
            replacement: 'bgd',
            source_labels: ['__param_target'],
            regex: 'https://prometheus-demo.bd.simple.org',
          },
          {
            target_label: 'environment',
            replacement: 'demo',
            source_labels: ['__param_target'],
            regex: 'https://prometheus-demo.bd.simple.org',
          },
          {
            target_label: 'country',
            replacement: 'lka',
            source_labels: ['__param_target'],
            regex: 'https://simples13.health.gov.lk/prometheus',
          },
          {
            target_label: 'environment',
            replacement: 'prod',
            source_labels: ['__param_target'],
            regex: 'https://simples13.health.gov.lk/prometheus',
          },
          {
            target_label: 'country',
            replacement: 'ind',
            source_labels: ['__param_target'],
            regex: 'https://prometheus.in.simple.org',
          },
          {
            target_label: 'environment',
            replacement: 'prod',
            source_labels: ['__param_target'],
            regex: 'https://prometheus.in.simple.org',
          },
        ],
      },
    ],
    ingress: {
      name: 'prometheus-k8s',
      host: 'prometheus.simple.org',
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
      name: 'simple-server-bgd',
      targets: ['https://api-demo.bd.simple.org'],
      labels: {
        service: 'simple_server',
        environment: 'staging',
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
      targets: ['https://simple.moh.gov.et/metabase/'],
      labels: {
        service: 'metabase',
        environment: 'prod',
        country: 'eth',
      },
      module: 'http_2xx',
    },
  ],
  alertmanager: {
    externalUrl: 'http://alertmanager.simple.org',
    ingress: {
      name: 'alertmanager-main',
      host: 'alertmanager.simple.org',
      port: 'web',
      path: '/',
    },
  },
  postgresNamespaces: [
    'simple-v1', 
    'dhis2-demo-ecuador', 
    'dhis2-sandbox-01', 
    'dhis2-sandbox-epidemics'
  ],
}
