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

local grafanaDashboards =
  postgres.grafanaDashboards +
  redis.grafanaDashboards +
  ingressNginx.grafanaDashboards +
  simpleServer.grafanaDashboards;


local prometheusRules = [
  postgres.prometheusRules,
  redis.prometheusRules,
  ingressNginx.prometheusRules,
];


local exporterServices = [
  postgres.exporterService,
  redis.exporterService,
  ingressNginx.exporterService,
  simpleServer.exporterService,
];

local serviceMonitors = [
  postgres.serviceMonitor,
  redis.serviceMonitor,
  ingressNginx.serviceMonitor,
  simpleServer.serviceMonitor,
];

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
        folderDashboards+: grafanaDashboards,
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
  prometheusRules +
  exporterServices +
  serviceMonitors;

argocd.addArgoAnnotations(manifests, kp.values.common.namespace)
