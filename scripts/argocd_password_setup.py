import json
import random
import string
import subprocess
import time

def generate_password(length=16):
 """Generate a random alphanumeric password with special characters."""
 characters = string.ascii_letters + string.digits + "!@#$%^&*()"
 return ''.join(random.choice(characters) for _ in range(length))

# Read users from file
with open('scripts/argocd_password_setup_users.txt', 'r') as file:
 users = [line.strip() for line in file]

# Read credentials from file
with open('scripts/argocd_password_setup_credentials.txt', 'r') as file:
 argocd_endpoints = [json.loads(line) for line in file]

for user in users:
 for endpoint in argocd_endpoints:
   # Login to the ArgoCD cluster
   login_command = f"argocd login {endpoint['url']} --username {endpoint['user']} --password '{endpoint['password']}' --grpc-web"
   subprocess.run(login_command, shell=True, check=True)

   # Sleep for 5 seconds to allow the login to complete
   time.sleep(5)
  
   # Update the password for the user
   new_password = generate_password()
   password_update_command = f"argocd account update-password --account {user} --current-password '{endpoint['password']}' --new-password '{new_password}' --grpc-web"
   subprocess.run(password_update_command, shell=True, check=True)
  
   print(f"argocd_endpoint: {endpoint['url']}, user: {user}, password: {new_password}")
