local common = (import 'lib/common.libsonnet');
local postgres = (import 'lib/postgres.libsonnet');
local redis = (import 'lib/redis.libsonnet');
local ingressNginx = (import 'lib/ingress-nginx.libsonnet');
local simpleServer = (import 'lib/simple-server.libsonnet');
local kubePrometheus = (import 'lib/kube-prometheus.libsonnet');
local argocd = (import 'lib/argocd.libsonnet');
local ingress = (import 'lib/ingress.libsonnet');

local environment = std.extVar('ENVIRONMENT');
local namespace = 'monitoring';

local isEnvSystemsProduction = environment == 'systems-production';

local config = {
  sandbox: (import 'config/sandbox.libsonnet'),
  'systems-production': (import 'config/systems-production.libsonnet'),
  'bangladesh-staging': (import 'config/bangladesh-staging.libsonnet'),
}[environment];

local monitoredServices =
  [postgres, redis, ingressNginx, simpleServer];

local grafanaDashboards =
  postgres.grafanaDashboards +
  redis.grafanaDashboards +
  ingressNginx.grafanaDashboards +
  simpleServer.grafanaDashboards;

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  (import 'kube-prometheus/addons/all-namespaces.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: namespace,
      },
      grafana+: {
        folderDashboards+: grafanaDashboards,
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
    ingress+:: ingress.ingressConfig([
      config.alertmanager.ingress {
        namespace: $.values.common.namespace,
        auth_secret: 'monitoring-basic-auth',
      },
      config.grafana.ingress {
        namespace: $.values.common.namespace,
      },
      config.prometheus.ingress {
        namespace: $.values.common.namespace,
        auth_secret: 'monitoring-basic-auth',
      },
    ]),
  };

local manifests =
  (if isEnvSystemsProduction then
     kubePrometheus.manifests(kp, isEnvSystemsProduction)
   else
     kubePrometheus.manifests(kp, isEnvSystemsProduction) +
     [service.prometheusRules for service in [postgres, redis, ingressNginx]] +
     [service.exporterService for service in monitoredServices] +
     [service.serviceMonitor for service in monitoredServices]);

argocd.addArgoAnnotations(manifests, kp.values.common.namespace)
