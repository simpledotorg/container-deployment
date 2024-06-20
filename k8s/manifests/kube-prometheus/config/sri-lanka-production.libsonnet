{
  grafana: {
    enable: false,
  },
  prometheus: {
    externalUrl: 'https://simples13.health.gov.lk',
    retention: {
      enable: false,
      retention: '1y',
      storage: '30Gi',
    },
    ingress: {
      name: 'prometheus-k8s',
      host: 'simples13.health.gov.lk',
      port: 'web',
      path: '/',
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
    externalUrl: 'http://simples13.health.gov.lk/alertmanager',
    ingress: {
      name: 'alertmanager-main',
      host: 'simples13.health.gov.lk',
      port: 'web',
      path: '/alertmanager(/|$)(.*)',
    },
  },
  postgresNamespaces: ['simple-v1'],
  sslEnabled: false,
}
