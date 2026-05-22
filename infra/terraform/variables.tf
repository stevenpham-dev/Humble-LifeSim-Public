variable "aws_region" {
  description = "AWS region used for the S3 bucket and Terraform-managed regional resources."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name used for naming and tags."
  type        = string
  default     = "humble-lifesim"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "prod"
}

variable "bucket_name_override" {
  description = "Optional globally unique S3 bucket name. Leave empty to auto-generate one using the AWS account ID."
  type        = string
  default     = ""
}

variable "force_destroy_bucket" {
  description = "If true, Terraform can delete the bucket even when objects exist. Useful for a portfolio demo."
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "CloudFront price class. PriceClass_100 is lower cost and enough for a portfolio demo."
  type        = string
  default     = "PriceClass_100"
}
