output "s3_bucket_name" {
  description = "Private S3 bucket used as the CloudFront origin."
  value       = aws_s3_bucket.web.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID used for cache invalidations."
  value       = aws_cloudfront_distribution.web.id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name."
  value       = aws_cloudfront_distribution.web.domain_name
}

output "cloudfront_url" {
  description = "Live HTTPS URL for the Humble LifeSim web demo."
  value       = "https://${aws_cloudfront_distribution.web.domain_name}"
}

output "upload_command" {
  description = "Run this from the repo root after exporting the Godot web build."
  value       = "aws s3 sync web-build s3://${aws_s3_bucket.web.bucket} --delete"
}

output "invalidation_command" {
  description = "Run this after uploading a new web build."
  value       = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.web.id} --paths \"/*\""
}
