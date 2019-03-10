variable "version" {
  description = "Version of the Lambda to use"
  type        = "string"
  default     = "v0.1.3"
}

variable "logging_bucket" {
  description = "S3 bucket to use for bucket logging"
  type        = "string"
}

variable "config_bucket" {
  description = "S3 bucket name to use for configuration"
  type        = "string"
}

variable "lambda_bucket" {
  description = "S3 bucket to use for reading Lambda source"
  type        = "string"
}
