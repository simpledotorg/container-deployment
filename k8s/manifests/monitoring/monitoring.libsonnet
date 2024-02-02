local kubernetes = import "kubernetes-mixin/mixin.libsonnet";

kubernetes {
  _config+:: {
    kubeStateMetricsSelector: 'job="kube-state-metrics"',
    cadvisorSelector: 'job="kubernetes-cadvisor"',
    nodeExporterSelector: 'job="kubernetes-node-exporter"',
    kubeletSelector: 'job="kubernetes-kubelet"',
    kubeApiserverSelector: 'job="kubernetes-apiservers"'
    grafanaK8s+:: {
      dashboardNamePrefix: 'Mixin / ',
      dashboardTags: ['kubernetes', 'infrastucture'],
    },
  },
}

