variable "aws_region" {
  description = "AWS region where launch the infrastructure"
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "app_name" {
  type    = string
  default = "michelcapitanio"
}

variable "lock_table_name" {
  type        = string
  description = "Name of the Dynamo DB table where store the lock"
  default     = "-terraform-state-locking"
}