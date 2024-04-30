local postgres = (import 'lib/postgres.libsonnet');
local redis = (import 'lib/redis.libsonnet');
local ingressNginx = (import 'lib/ingress-nginx.libsonnet');
local simpleServer = (import 'lib/simple-server.libsonnet');
local kubePrometheus = (import 'lib/kube-prometheus.libsonnet');
local argocd = (import 'lib/argocd.libsonnet');
local ingress = (import 'lib/ingress.libsonnet');

local grafanaDashboards =
  postgres.grafanaDashboards +
  redis.grafanaDashboards +
  ingressNginx.grafanaDashboards;


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
        namespace: 'monitoring',
      },
      grafana+: {
        folderDashboards+: grafanaDashboards,
        config+: {
          sections+: {
            server+: {
              root_url: 'http://grafana-sandbox.simple.org/',
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
          externalUrl: 'http://alertmanager-sandbox.simple.org',
        },
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: 'http://prometheus-sandbox.simple.org',
        },
      },
    },
    ingress+:: ingress.ingressConfig([
      {
        name: 'alertmanager-main',
        namespace: $.values.common.namespace,
        host: 'alertmanager-sandbox.simple.org',
        port: 'web',
      },
      {
        name: 'grafana',
        namespace: $.values.common.namespace,
        host: 'grafana-sandbox.simple.org',
        port: 'http',
      },
      {
        name: 'prometheus-k8s',
        namespace: $.values.common.namespace,
        host: 'prometheus-sandbox.simple.org',
        port: 'web',
      },
    ]),
  };

local manifests =
  kubePrometheus.manifests(kp) +
  prometheusRules +
  exporterServices +
  serviceMonitors;

argocd.addArgoAnnotations(manifests, kp.values.common.namespace)
