
# Output the bucket arn
output "bucket_arn" {
  value = aws_s3_bucket.simple_s3.arn
}

# Output the access key
output "access_key" {
  value = aws_iam_access_key.simple_s3_user_access_key.id
}

# Output the access secret
output "access_secret" {
  value     = aws_iam_access_key.simple_s3_user_access_key.secret
  sensitive = true
}

# User arn
output "user_arn" {
  value = aws_iam_user.simple_s3_user.arn
}
