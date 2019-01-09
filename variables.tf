variable "version" {
  type    = "string"
  default = "0.0.4"
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
