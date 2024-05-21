{
  manifests(kp, isEnvSystemsProduction=false):
    // alertmanager is configured using sealed-secrets
    local alertmanager = std.mergePatch(kp.alertmanager, { secret: null });

    // grafana is configured using sealed-secrets
    local grafana = std.mergePatch(kp.grafana, {
      config: null,

      // We want to configure multiple datasources in systems production env.
      // This secret is configured using sealed-secrets
      [if isEnvSystemsProduction then 'dashboardDatasources']: null,
    });

    [kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus)] +
    [kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator)] +
    [alertmanager[name] for name in std.objectFields(alertmanager)] +
    [kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter)] +
    [grafana[name] for name in std.objectFields(grafana)] +
    [kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics)] +
    [kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane)] +
    [kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter)] +
    [kp.prometheus[name] for name in std.objectFields(kp.prometheus)] +
    [kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter)] +
    [kp.ingress[name] for name in std.objectFields(kp.ingress)],
}
