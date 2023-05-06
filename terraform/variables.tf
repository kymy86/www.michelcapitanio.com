variable "aws_region" {
  default = "eu-central-1"
  type    = string
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "website_name" {
  description = "Name of your personal website"
  type        = string
  default     = "michelcapitanio.com"
}
