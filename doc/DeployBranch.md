## Deploy a specific branch to test k8s manifest changes

### Disable Argocd root app auto sync
To avoid brach override for specif apps
![image](https://raw.githubusercontent.com/simpledotorg/container-deployment/master/doc/images/argocd-disable-autosync.png)

### Updated for a specific app
Change `targetRevision` and save the application manifest
![image](https://raw.githubusercontent.com/simpledotorg/container-deployment/master/doc/images/argocd-app-edit-target-revision.png)

Note: Enable root auto sync post testing
