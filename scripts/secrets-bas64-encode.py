import yaml
import base64

with open("../k8s/argocd-apps/bd-k3s-demo/secrets/simple-server.sealedsecret.yaml", 'r') as stream:
  try:
    parsed_yaml=yaml.safe_load(stream)
    for key, value in parsed_yaml['data'].items():
      if value is not None:
        base64_string = base64.b64encode(str(value).encode('utf-8')).decode('utf-8')
      else:
        base64_string = ""
        
      print("%s: \"%s\"" % (key, base64_string))
  except yaml.YAMLError as exc:
    print(exc)
