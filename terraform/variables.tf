variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
}

variable "website_name" {
  description = "Name of your personal website"
}

variable "hosted_ids" {
  type = "map"

  default = {
    us-east-2    = "Z2O1EMRO9K5GLX"
    us-east-1    = "Z3AQBSTGFYJSTF"
    us-west-1    = "Z2F56UZL2M1ACD"
    us-west-2    = "Z3BJ6K6RIION7M"
    eu-central-1 = "Z21DNDUVLTQW6Q"
    eu-west-1    = "Z1BKCTXD74EZPE"
    eu-west-2    = "Z3GKZC51ZF0DB4"
    eu-west-3    = "Z3R1K369G5AVDG"
  }
}
