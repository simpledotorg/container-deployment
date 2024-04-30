local rule(name, host, port) = {
  host: host,
  http: {
    paths: [{
      path: '/',
      pathType: 'Prefix',
      backend: {
        service: {
          name: name,
          port: {
            name: port,
          },
        },
      },
    }],
  },
};

local tls(host) = {
  hosts: [host],
  secretName: host + '-tls',
};

local ingress(name, namespace, host, port) = {
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: name,
    namespace: namespace,
    annotations: {
      'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
      'nginx.ingress.kubernetes.io/force-ssl-redirect': 'true',

    },
  },
  spec: { rules: [rule(name, host, port)], tls: [tls(host)] },
};


{
  ingressConfig(configs): {
    [config.name]: ingress(
      config.name,
      config.namespace,
      config.host,
      config.port,
    )
    for config in configs
  },
}
