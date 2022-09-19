#!/usr/bin/env python3

import yaml
import base64
import sys
import subprocess

def decrypt(secret_file, k8s_host, k8s_host_user):
  f = open(secret_file, "r")
  parsed_yaml=yaml.safe_load(f.read())
  f.close()

  name = parsed_yaml["metadata"]["name"]
  namespace = parsed_yaml["metadata"]["namespace"]

  bashCommand = "ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no %s@%s kubectl get secrets -n %s %s -o yaml" %(k8s_host_user, k8s_host, namespace, name)
  process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
  output, error = process.communicate()

  f = open(secret_file + ".decrypted", "w")
  f.write(output.decode("utf-8"))
  f.close()

def usage():
  sys.stderr.write("Usage: %s <sealed secret file name> <k8s host ip> <host ssh user>\n" % (sys.argv[0]))

if __name__ == '__main__':
  try:
    arg = sys.argv[1]
  except IndexError:
    arg = None

  if len(sys.argv[1:]) != 3:
    usage()
    exit(1)

  args = sys.argv[1:]
  secret_file = args[0]
  k8s_host = args[1]
  k8s_host_user = args[2]

  decrypt(secret_file, k8s_host, k8s_host_user)
