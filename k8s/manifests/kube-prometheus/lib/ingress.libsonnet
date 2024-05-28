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

local ingress(name, namespace, host, port, auth_secret=null) =
  local auth_annotations = {
    'nginx.ingress.kubernetes.io/auth-type': 'basic',
    'nginx.ingress.kubernetes.io/auth-secret': auth_secret,
    'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
  };

  {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: name,
      namespace: namespace,
      annotations: {
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
        'nginx.ingress.kubernetes.io/force-ssl-redirect': 'true',
      } + (if auth_secret != null then auth_annotations else {}),
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
      std.get(config, 'auth_secret')
    )
    for config in configs
  },
}
