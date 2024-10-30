# Loki
Loki is a tool for storing and querying logs.

## Architecture
Loki supports multiple deployment options, and we use a simple, scalable deployment model. More details can be found [here](https://grafana.com/docs/loki/latest/get-started/deployment-modes/).

## Deployment
Loki is deployed using a Helm chart. Chart details are available [here](https://github.com/grafana/loki/tree/main/production/helm/loki). We have created a wrapper around this Helm chart to set optimized defaults for our use case, available [here](../k8s/manifests/loki/). Environment-specific configurations are found in the environment values folder, such as [this example](/k8s/environments/sandbox/values/loki.yaml).

## Loki Data Source
The Loki data source endpoint is exposed to the internet via a Loki gateway secured with basic authentication. This endpoint is also added as a data source in our central Grafana instance at `https://grafana.simple.org/`.

## Log Retention
In our setup, log retention is set to four weeks. This can be modified in the Helm chart values. Logs are stored in an S3 bucket.

## Logs Ingestion
We use Promtail to ingest logs into Loki. Promtail is deployed as a DaemonSet across all nodes in the cluster.

## Alert Rules
Alert rules can be added to Loki, which works with Prometheus Alertmanager to send notifications to Slack. Alert rules can be configured in the Helm values file, for example, see [here](../k8s/manifests/loki/values.yaml).

## Metrics
Both Loki and Promtail expose metrics, prefixed with `loki_` or `promtail_` respectively. These metrics are sent to Prometheus. A set of default Loki dashboards is available in Grafana under the "Loki" folder. Additionally, Loki offers a mixin for setting up dashboards and alerts, which you can find [here](https://github.com/grafana/loki/tree/main/production). We use this mixin for creating default dashboards in our setup, found [here](../k8s/manifests/kube-prometheus/lib/loki.libsonnet).
