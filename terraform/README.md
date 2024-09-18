# Terraform - Infrastructure as Code

## Setup

Install Terraform CLI

```
brew install tfenv
tfenv install 1.4.6 # or any version
tfenv use 1.4.6 # or any version
```

AWS profiles: Terraform uses AWS profiles to connect to AWS and make sure you have the same profile name in `~/.aws/credentials` file.
The profile name will be mentioned in the backend section of the `main.tf` file.

Sample: [file](sandbox/main.tf)
```
terraform {
  ...
  backend "s3" {
    ...
    profile        = "development"
  }
}
```

AWS Key Pair: Ensure the public key of the AWS key pair, retrieved from 1Password (`AWS Master SSH Key`), is placed in the `~/.ssh/simple_aws_key.pub` file

Validate the changes
```
terraform plan

# Please review the changes carefully, especially the resources getting destroyed
# If you are not sure about the changes, please ask for help in #engineers slack channel
```

Apply the changes
```
terraform apply
```

Check the outputs
```
terraform output
```

## View sensitive outputs

```bash
terraform console
nonsensitive(module.db_backup_s3_bucket.access_secret)
```
