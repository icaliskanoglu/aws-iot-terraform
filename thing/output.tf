variable "outputs_path" {
  type = string
}

variable "region" {
  type = string
}

locals {
  version = "${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
}

#save certificate files
resource "local_file" "thing-certificate-cert" {
  content  = "${aws_iot_certificate.thing-certificate.certificate_pem}"
  filename = "${var.outputs_path}/certificate.pem.cert"
}

resource "local_file" "thing-certificate-pub" {
  content  = "${aws_iot_certificate.thing-certificate.public_key}"
  filename = "${var.outputs_path}/public.pem.key"
}

resource "local_file" "thing-certificate-pri" {
  content  = "${aws_iot_certificate.thing-certificate.private_key}"
  filename = "${var.outputs_path}/private.pem.key"
}

resource "local_file" "thing-config" {
  content  = templatefile("${path.module}/thing-conf.json.tpl", {
    DEVICE_NAMES   = jsonencode([for r in aws_iot_thing.thing : "${r.name}"])
    THING_GROUP = "${var.thing_group}"
    REGION = "${var.region}"
    SERVICE_ROLE_ALIAS = "${aws_iot_role_alias.thing-service-role-alias.alias}"
    DEPLOYMENT_BUCKET = "${aws_s3_bucket.thing-deployment-bucket.bucket}"
    VERSION = "${local.version}"
  })
  filename = "${var.outputs_path}/conf.json"
}