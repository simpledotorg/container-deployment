{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://simples13.health.gov.lk/prometheus',
    retention: {
      enable: false,
      retention: '1y',
      storage: '30Gi',
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
      path: '/prometheus(/|$)(.*)',
    },
  },
  postgresNamespaces: ['simple-v1'],
  sslEnabled: false,
}
