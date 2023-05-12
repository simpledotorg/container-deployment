variable "bucket_name" {
  type = string
}

# S3 actions allowed for the user for this bucket
# S3 actions: https://docs.aws.amazon.com/AmazonS3/latest/dev/using-with-s3-actions.html
variable "allowed_actions" {
  type = array(string)
  default = [
    "s3:*" # Allow all actions
  ]
}

variable "tags" {
  type = map(string)
}
