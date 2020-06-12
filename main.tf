
variable "region" {
  type    = string
  default = "eu-central-1"
}

#since terraform is not supporting thing group yet, we will user this variable as prefix
variable "thing_group" {
  type = string
}

variable "organization_name" {
  type = string
}

variable "device_ids" {
  description = "Create thing for users"
  type        = list(string)
}

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "jff-thing-deployment-frankfurt"
    key    = "terraform-state/terraform.tfstate"
    region = "eu-central-1"
  }
}


module "thing" {
  source            = "./thing"
  outputs_path      = "${path.module}/outputs"
  region            = "${var.region}"
  thing_group       = "${var.thing_group}"
  device_ids        = "${var.device_ids}"
  organization_name = "${var.organization_name}"
}
