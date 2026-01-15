# Datadog Decommissioning Notes

Decommissioning Datadog is a straightforward process. We have deployed Datadog using the [Datadog Operator](https://docs.datadoghq.com/containers/datadog_operator/). To fully disable Datadog, first remove the Datadog agent, followed by the operator.

Both the agent and operator applications are defined in `k8s/environments/<env>/argocd-apps/apps.yaml`. Remove the application entries from this file and sync the root app in ArgoCD to complete the uninstallation. Additionally, remove any related configurations and secrets associated with Datadog to avoid future confusion.

Since Datadog also manages logging, consider deploying Loki to ensure log retention for future debugging.

If you need to disable only metrics and APM while retaining log functionality, please refer to this [PR](https://github.com/simpledotorg/container-deployment/pull/170) and the [Datadog documentation](https://docs.datadoghq.com/logs/guide/how-to-set-up-only-logs/?tab=kubernetes).
