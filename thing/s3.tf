variable "organization_name" {
  type = string
}

resource "aws_s3_bucket" "thing-deployment-bucket" {
  bucket = "${var.organization_name}-thing-${var.thing_group}-deployment"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name = "${var.organization_name}-thing-${var.thing_group}-deployment"
  }
}
