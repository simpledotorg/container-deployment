resource "aws_s3_bucket" "simple_s3" {
  bucket = var.bucket_name
  acl    = "private"
  tags = merge(
    {
      Name      = var.bucket_name
      Terrafrom = "true"
    },
    var.tags
  )
}

resource "aws_iam_user" "simple_s3_user" {
  name = var.bucket_name
}

data "aws_iam_policy_document" "simple_s3_policy" {
  statement {
    actions   = var.allowed_actions
    effect    = "Allow"
    resources = [aws_s3_bucket.simple_s3.arn, "${aws_s3_bucket.simple_s3.arn}/*"]
  }
}

resource "aws_iam_policy" "simple_s3_policy" {
  name        = var.bucket_name
  description = "Allow access to simple-s3-bucket"
  policy      = data.aws_iam_policy_document.simple_s3_policy.json
}

resource "aws_iam_user_policy_attachment" "simple_s3_user_policy" {
  user       = aws_iam_user.simple_s3_user.name
  policy_arn = aws_iam_policy.simple_s3_policy.arn
}

resource "aws_iam_access_key" "simple_s3_user_access_key" {
  user = aws_iam_user.simple_s3_user.name
}
