function(namespace, blackboxExporterServiceName, probeConfigs)[
    {
        apiVersion: 'monitoring.coreos.com/v1',
        kind: 'Probe',
        metadata:{
            name: 'blackbox-' + probe.name,
            namespace: namespace,
        },
        spec: {
          jobName: 'blackbox-' + probe.name,
          interval: '30s',
          module: probe.module,
          prober: {
            url: blackboxExporterServiceName + '.' + namespace + '.svc.cluster.local:9115',
          },
          targets: {
            staticConfig: {
              targets: probe.targets,
            },
          },
        },
    }
    for probe in probeConfigs
]
