variable "version" {
  type    = "string"
  default = "v0.1.0"
}

variable "logging-bucket" {
  type = "string"
}

variable "topic" {
  type = "string"
}

variable "config-bucket" {
  type = "string"
}

variable "lambda-bucket" {
  type    = "string"
  default = "akerl-sns-to-slack"
}
