// NB! Make sure that argocd-cm has `application.instanceLabelKey` set to something else than `app.kubernetes.io/instance`,
//     otherwise it will cause problems with prometheus target discovery.
//     See also https://argo-cd.readthedocs.io/en/stable/faq/#why-is-my-app-out-of-sync-even-after-syncing

local ingress(name, namespace, rules) = {
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: name,
    namespace: namespace,
    annotations: {
      'nginx.ingress.kubernetes.io/auth-type': 'basic',
      'nginx.ingress.kubernetes.io/auth-secret': 'basic-auth',
      'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
    },
  },
  spec: { rules: rules },
};

local grafana_root_url = std.extVar("GRAFANA_ROOT_URL");
local alertmanager_url = std.extVar("ALERTMANAGER_URL");
local prometheus_url = std.extVar("PROMETHEUS_URL");
local kp =
  (import 'kube-prometheus/main.libsonnet') +
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
      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: grafana_root_url,
            },
          },
        },
      },
    },
    alertmanager+:: {
      alertmanager+: {
        spec+: {
          externalUrl: alertmanager_url,
        },
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: prometheus_url ,
        },
      },
    },
    ingress+:: {
      'alertmanager-main': ingress(
        'alertmanager-main',
        $.values.common.namespace,
        [{
          host: alertmanager_url,
          http: {
            paths: [{
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'alertmanager-main',
                  port: {
                    name: 'web',
                  },
                },
              },
            }],
          },
        }]
      ),
      grafana: ingress(
        'grafana',
        $.values.common.namespace,
        [{
          host: grafana_root_url,
          http: {
            paths: [{
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'grafana',
                  port: {
                    name: 'http',
                  },
                },
              },
            }],
          },
        }],
      ),
      'prometheus-k8s': ingress(
        'prometheus-k8s',
        $.values.common.namespace,
        [{
          host: prometheus_url,
          http: {
            paths: [{
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'prometheus-k8s',
                  port: {
                    name: 'web',
                  },
                },
              },
            }],
          },
        }],
      ),
    },
  };

// Unlike in kube-prometheus/example.jsonnet where a map of file-names to manifests is returned,
// for ArgoCD we need to return just a regular list with all the manifests.
local manifests =
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
  [kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter)];

local argoAnnotations(manifest) =
  manifest {
    metadata+: {
      annotations+: {
        'argocd.argoproj.io/sync-wave':
          // Make sure to sync the Namespace & CRDs before anything else (to avoid sync failures)
          if std.member(['CustomResourceDefinition', 'Namespace'], manifest.kind)
          then '-5'
          // And sync all the roles outside of the main & kube-system last (in case some of the namespaces don't exist yet)
          else if std.objectHas(manifest, 'metadata')
                  && std.objectHas(manifest.metadata, 'namespace')
                  && !std.member([kp.values.common.namespace, 'kube-system'], manifest.metadata.namespace)
          then '10'
          else '5',
        'argocd.argoproj.io/sync-options':
          // Use replace strategy for CRDs, as they're too big fit into the last-applied-configuration annotation that kubectl apply wants to use
          if manifest.kind == 'CustomResourceDefinition' then 'Replace=true'
          else '',
      },
    },
  };

// Add argo-cd annotations to all the manifests
[
  if std.endsWith(manifest.kind, 'List') && std.objectHas(manifest, 'items')
  then manifest { items: [argoAnnotations(item) for item in manifest.items] }
  else argoAnnotations(manifest)
  for manifest in manifests
]
