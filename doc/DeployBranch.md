## Deploy a specific branch to test k8s manifest changes

### Disable Argocd root app auto sync
To avoid brach override for specif apps
![image](./images/argocd-disable-autosync.png?raw=true)

### Updated for a specific app
Change `targetRevision` and save the application manifest
![image](./images/argocd-app-edit-target-revision.png?raw=true)

Note: Enable root auto sync post testing
