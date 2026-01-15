function(namespace, probeConfigs)[
    {
        apiVersion: 'monitoring.coreos.com/v1',
        kind: 'Probe',
        metadata:{
            name: 'blackbox-' + probe.name,
            namespace: namespace,
            labels:{
              release: 'prometheus-stack',
            },
        },
        spec: {
          jobName: 'blackbox-' + probe.name,
          interval: '30s',
          module: probe.module,
          prober: {
            path: '/probe',
            url: 'blackbox-exporter.monitoring.svc.cluster.local:19115',
          },
          targets: {
            staticConfig: {
              static: probe.targets,
              labels: probe.labels,
            },
          },
        },
    }
    for probe in probeConfigs
]
