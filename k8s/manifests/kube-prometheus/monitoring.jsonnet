local common = (import 'lib/common.libsonnet');
local postgres = (import 'lib/postgres.libsonnet');
local redis = (import 'lib/redis.libsonnet');
local ingressNginx = (import 'lib/ingress-nginx.libsonnet');
local simpleServer = (import 'lib/simple-server.libsonnet');
local kubePrometheus = (import 'lib/kube-prometheus.libsonnet');
local argocd = (import 'lib/argocd.libsonnet');
local ingress = (import 'lib/ingress.libsonnet');
local dhis2Server = (import 'lib/dhis2-server.libsonnet');
local alphasms = (import 'lib/alphasms.libsonnet');
local loki = (import 'lib/loki.libsonnet');

local environment = std.extVar('ENVIRONMENT');
local namespace = 'monitoring';

local config = {
  sandbox: (import 'config/sandbox.libsonnet'),
  'systems-production': (import 'config/systems-production.libsonnet'),
  'bangladesh-staging': (import 'config/bangladesh-staging.libsonnet'),
  'bangladesh-production': (import 'config/bangladesh-production.libsonnet'),
  'sri-lanka-production': (import 'config/sri-lanka-production.libsonnet'),
  'india-production': (import 'config/india-production.libsonnet'),
}[environment];

local isEnvSystemsProduction = environment == 'systems-production';
local isEnvSandbox = environment == 'sandbox';
local enableGrafana = config.grafana.enable;
local enableDhis2Dashboards = std.objectHas(config.grafana, 'enableDhis2Dashboards') && config.grafana.enableDhis2Dashboards;
local sslEnabled = if std.objectHas(config, 'sslEnabled') then config.sslEnabled else true;

local monitoredServices =
  [redis, ingressNginx, simpleServer];

local grafanaDashboards =
  postgres.grafanaDashboards +
  alphasms.grafanaDashboards +
  redis.grafanaDashboards +
  ingressNginx.grafanaDashboards +
  simpleServer.grafanaDashboards +
  loki.grafanaDashboards +
  (if enableDhis2Dashboards then dhis2Server.grafanaDashboards else {});

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  (import 'kube-prometheus/addons/all-namespaces.libsonnet') +
  (import 'kube-prometheus/addons/networkpolicies-disabled.libsonnet') +
  (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: namespace,
      },
      grafana+: {
        [if enableGrafana then 'folderDashboards']+: grafanaDashboards,
        [if isEnvSandbox then 'datasources']+: [
          {
            type: 'loki',
            url: 'http://loki-read.loki.svc.cluster.local:3100',
            access: 'proxy',
            isDefault: false,
            orgId: 1,
            editable: false,
          },
        ],
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
          [if config.prometheus.retention.enable then 'retention']: config.prometheus.retention.retention,
          [if config.prometheus.retention.enable then 'storage']: {
            volumeClaimTemplate: {
              apiVersion: 'v1',
              kind: 'PersistentVolumeClaim',
              spec: {
                accessModes: ['ReadWriteOnce'],
                resources: {
                  requests: {
                    storage: config.prometheus.retention.storage,
                  },
                },
              },
            },
          },
          [if std.objectHas(config.prometheus, 'affinity') && config.prometheus.affinity != null then 'affinity']: config.prometheus.affinity,
        },
      },
    },
    ingress+:: ingress.ingressConfig(
      [
        config.alertmanager.ingress {
          namespace: $.values.common.namespace,
          auth_secret: 'monitoring-basic-auth',
          sslEnabled: sslEnabled,
        },
        config.prometheus.ingress {
          namespace: $.values.common.namespace,
          auth_secret: 'monitoring-basic-auth',
          sslEnabled: sslEnabled,
        },
      ] + (if enableGrafana then [config.grafana.ingress { namespace: $.values.common.namespace, sslEnabled: sslEnabled }] else []),
    ),
  };

local manifests =
  (if isEnvSystemsProduction then
    kubePrometheus.manifests(kp, isEnvSystemsProduction, enableGrafana)
   else
    kubePrometheus.manifests(kp, isEnvSystemsProduction, enableGrafana) +
    [service.prometheusRules for service in monitoredServices] +
    [service.exporterService for service in monitoredServices] +
    [service.serviceMonitor for service in monitoredServices]) +
  [postgres.prometheusRules] +
  postgres.monitors(config.postgresNamespaces).exporterServices +
  postgres.monitors(config.postgresNamespaces).serviceMonitors +
  (if isEnvSandbox then [alphasms.prometheusRules] else []);

argocd.addArgoAnnotations(manifests, kp.values.common.namespace)
