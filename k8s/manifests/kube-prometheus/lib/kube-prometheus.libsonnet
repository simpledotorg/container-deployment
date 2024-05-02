{
  manifests(kp):
    [kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus)] +
    [kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator)] +
    [kp.alertmanager[name] for name in std.objectFields(kp.alertmanager)] +
    [kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter)] +
    [kp.grafana[name] for name in std.objectFields(kp.grafana)] +
    // [ kp.pyrra[name] for name in std.objectFields(kp.pyrra)] +
    [kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics)] +
    [kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane)] +
    [kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter)] +
    [kp.prometheus[name] for name in std.objectFields(kp.prometheus)] +
    [kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter)] +
    [kp.ingress[name] for name in std.objectFields(kp.ingress)],
}
