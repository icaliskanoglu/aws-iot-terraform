variable "organization_name" {
  type = string
}

data "aws_region" "current" {
}

resource "aws_s3_bucket" "thing-deployment-bucket" {
  bucket = "${var.organization_name}-thing-deployment-${var.thing_group}-${data.aws_region.current.name}"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name = "${var.organization_name}-thing-deployment-${var.thing_group}-${data.aws_region.current.name}"
  }
}
