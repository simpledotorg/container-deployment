local common = (import 'lib/common.libsonnet');
local postgres = (import 'lib/postgres.libsonnet');
local redis = (import 'lib/redis.libsonnet');
local ingressNginx = (import 'lib/ingress-nginx.libsonnet');
local simpleServer = (import 'lib/simple-server.libsonnet');
local kubePrometheus = (import 'lib/kube-prometheus.libsonnet');
local argocd = (import 'lib/argocd.libsonnet');
local ingress = (import 'lib/ingress.libsonnet');
local dhis2Server = (import 'lib/dhis2-server.libsonnet');

local environment = std.extVar('ENVIRONMENT');
local namespace = 'monitoring';

local config = {
  sandbox: (import 'config/sandbox.libsonnet'),
  'systems-production': (import 'config/systems-production.libsonnet'),
  'bangladesh-staging': (import 'config/bangladesh-staging.libsonnet'),
  'bangladesh-production': (import 'config/bangladesh-production.libsonnet'),
}[environment];

local isEnvSystemsProduction = environment == 'systems-production';
local enableGrafana = config.grafana.enable;

local monitoredServices =
  [postgres, redis, ingressNginx, simpleServer];

local grafanaDashboards =
  postgres.grafanaDashboards +
  redis.grafanaDashboards +
  ingressNginx.grafanaDashboards +
  simpleServer.grafanaDashboards +
  dhis2Server.grafanaDashboards;

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  (import 'kube-prometheus/addons/all-namespaces.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: namespace,
      },
      grafana+: {
        [if enableGrafana then 'folderDashboards']+: grafanaDashboards,
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
          retention: config.prometheus.retention,
          storage: {
            volumeClaimTemplate: {
              apiVersion: 'v1',
              kind: 'PersistentVolumeClaim',
              spec: {
                accessModes: ['ReadWriteOnce'],
                resources: {
                  requests: {
                    storage: config.prometheus.storage,
                  },
                },
              },
            },
          },
        },
      },
    },
    ingress+:: ingress.ingressConfig(
      [
        config.alertmanager.ingress {
          namespace: $.values.common.namespace,
          auth_secret: 'monitoring-basic-auth',
        },
        config.prometheus.ingress {
          namespace: $.values.common.namespace,
          auth_secret: 'monitoring-basic-auth',
        },
      ] + (if enableGrafana then [config.grafana.ingress { namespace: $.values.common.namespace }] else []),
    ),
  };

local manifests =
  (if isEnvSystemsProduction then
     kubePrometheus.manifests(kp, isEnvSystemsProduction, enableGrafana)
   else
     kubePrometheus.manifests(kp, isEnvSystemsProduction, enableGrafana) +
     [service.prometheusRules for service in monitoredServices] +
     [service.exporterService for service in monitoredServices] +
     [service.serviceMonitor for service in monitoredServices]);

argocd.addArgoAnnotations(manifests, kp.values.common.namespace)
