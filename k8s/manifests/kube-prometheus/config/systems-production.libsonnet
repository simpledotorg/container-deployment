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
