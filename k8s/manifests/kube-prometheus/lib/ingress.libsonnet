local rule(name, host, port, path) = {
  host: host,
  http: {
    paths: [{
      path: path,
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

local ingress(name, namespace, host, port, auth_secret=null, sslEnabled=true, path) =
  local auth_annotations = {
    'nginx.ingress.kubernetes.io/auth-type': 'basic',
    'nginx.ingress.kubernetes.io/auth-secret': auth_secret,
    'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
  };

  local ssl_annotations = {
    'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
    'nginx.ingress.kubernetes.io/force-ssl-redirect': 'true',
  };

  {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: name,
      namespace: namespace,
      annotations: (if sslEnabled then ssl_annotations else {}) +
                   (if auth_secret != null then auth_annotations else {}),
    },
    spec: { rules: [rule(name, host, port, path)] } +
          (if sslEnabled then { tls: [tls(host)] } else {}),
  };


{
  ingressConfig(configs): {
    [config.name]: ingress(
      config.name,
      config.namespace,
      config.host,
      config.port,
      std.get(config, 'auth_secret'),
      config.sslEnabled,
      config.path
    )
    for config in configs
  },
}
