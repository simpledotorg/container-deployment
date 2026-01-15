
output "bucket_id" {
  value = aws_s3_bucket.simple_s3.id
}

output "bucket_arn" {
  value = aws_s3_bucket.simple_s3.arn
}

output "access_key" {
  value = aws_iam_access_key.simple_s3_user_access_key.id
}

output "access_secret" {
  value     = aws_iam_access_key.simple_s3_user_access_key.secret
  sensitive = true
}

output "user_arn" {
  value = aws_iam_user.simple_s3_user.arn
}
