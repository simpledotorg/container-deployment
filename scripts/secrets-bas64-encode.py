import yaml
import base64

with open("../k8s/argocd-apps/bd-k3s-demo/secrets/simple-server.sealedsecret.yaml", 'r') as stream:
  try:
    parsed_yaml=yaml.safe_load(stream)
    for key, value in parsed_yaml['data'].items():
      base64_string = base64.b64encode(value.encode('utf-8'))
      print("%s: \"%s\"" % (key, base64_string.decode('utf-8')))
  except yaml.YAMLError as exc:
    print(exc)
