local postgres = (import 'lib/postgres.libsonnet');
local redis = (import 'lib/redis.libsonnet');
local ingressNginx = (import 'lib/ingress-nginx.libsonnet');
local simpleServer = (import 'lib/simple-server.libsonnet');
local kubePrometheus = (import 'lib/kube-prometheus.libsonnet');
local argocd = (import 'lib/argocd.libsonnet');
local ingress = (import 'lib/ingress.libsonnet');

local environment = std.extVar('ENVIRONMENT');
local namespace = 'monitoring';

local config = {
  sandbox: (import 'config/sandbox.libsonnet'),
}[environment];

local monitoredServices =
  [postgres, redis, ingress, simpleServer];

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  (import 'kube-prometheus/addons/all-namespaces.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  // (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/pyrra.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: namespace,
      },
      grafana+: {
        folderDashboards+: std.sum([service.grafanaDashboards for service in monitoredServices]),
        datasources+: [],
        config+: {
          sections+: {
            server+: {
              root_url: config.grafana.externalUrl,
            },
          },
        },
      },
      prometheus+: {
        namespaces: [],
      },
      alertmanager+: {
        config: importstr 'alertmanager-config.yaml',
      },
    },
    alertmanager+:: {
      alertmanager+: {
        spec+: {
          externalUrl: config.alertmanager.externalUrl,
        },
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: config.prometheus.externalUrl,
        },
      },
    },
    ingress+:: ingress.ingressConfig([
      config.alertmanager.ingress {
        namespace: $.values.common.namespace,
      },
      config.grafana.ingress {
        namespace: $.values.common.namespace,
      },
      config.prometheus.ingress {
        namespace: $.values.common.namespace,
      },
    ]),
  };

local manifests =
  kubePrometheus.manifests(kp) +
  [service.prometheusRules for service in monitoredServices] +
  [service.exporterServices for service in monitoredServices] +
  [service.serviceMonitors for service in monitoredServices];

argocd.addArgoAnnotations(manifests, kp.values.common.namespace)
