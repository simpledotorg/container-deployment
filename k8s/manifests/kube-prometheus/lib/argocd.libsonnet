local argoAnnotations(manifest, namespace) =
  manifest {
    metadata+: {
      annotations+: {
        'argocd.argoproj.io/sync-wave':
          if std.member(['CustomResourceDefinition', 'Namespace'], manifest.kind)
          then '-5'
          else if std.objectHas(manifest, 'metadata')
                  && std.objectHas(manifest.metadata, 'namespace')
                  && !std.member([namespace, 'kube-system'], manifest.metadata.namespace)
          then '10'
          else '5',
        'argocd.argoproj.io/sync-options':
          if manifest.kind == 'CustomResourceDefinition' then 'Replace=true'
          else '',
      },
    },
  };

{
  addArgoAnnotations(manifests, namespace):
    [
      if std.endsWith(manifest.kind, 'List') && std.objectHas(manifest, 'items')
      then manifest { items: [argoAnnotations(item, namespace) for item in manifest.items] }
      else argoAnnotations(manifest, namespace)
      for manifest in manifests
    ],
}
