#the thing

variable "thing_group" {
  type = string
}

variable "device_ids" {
  description = "DeviceOds"
  type        = list(string)
}


resource "aws_iot_thing" "thing" {
  for_each = toset(var.device_ids)
  name     = "${var.thing_group}-${each.value}"
  attributes = {
    Name = "${var.thing_group}-${each.value}"
  }
}

#the thing certificate
resource "aws_iot_certificate" "thing-certificate" {
  active = true
}

#attch thing to certificate
resource "aws_iot_thing_principal_attachment" "thing-certificate-attachment" {
  for_each  = aws_iot_thing.thing
  principal = "${aws_iot_certificate.thing-certificate.arn}"
  thing     = "${each.value.name}"
}

#certificate iot policy
data "aws_iam_policy_document" "thing-policy-document" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "iot:*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iot_policy" "thing-policy" {
  name   = "${var.thing_group}-policy"
  policy = "${data.aws_iam_policy_document.thing-policy-document.json}"
}

resource "aws_iot_policy_attachment" "thing-policy-attachment" {
  policy = "${aws_iot_policy.thing-policy.name}"
  target = "${aws_iot_certificate.thing-certificate.arn}"
}

#assume with certificate policy
data "aws_iam_policy_document" "thing-assume-with-cert-policy-document" {
  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "iot:AssumeRoleWithCertificate",
    ]
    resources = [
      "${aws_iot_role_alias.thing-service-role-alias.arn}",
    ]
  }
}

resource "aws_iot_policy" "thing-assume-with-cert-policy" {
  name   = "${var.thing_group}-assume-with-cert-policy"
  policy = "${data.aws_iam_policy_document.thing-assume-with-cert-policy-document.json}"
}

resource "aws_iot_policy_attachment" "thing-assume-with-cert-policy-attachment" {
  policy = "${aws_iot_policy.thing-assume-with-cert-policy.name}"
  target = "${aws_iot_certificate.thing-certificate.arn}"
}


resource "aws_iot_topic_rule" "rule" {
  name        = "ThingShadowRule"
  description = "ThingShadowRule"
  enabled     = true
  sql         = "SELECT * , topic(3) as thingname FROM '$aws/things/+/shadow/update'"
  sql_version = "2016-03-23"

  s3 {
    bucket_name = "${aws_s3_bucket.thing-shadow-bucket.bucket}"
    role_arn    = "${aws_iam_role.thing-shadow-rule-role.arn}"
    key         = "things/shadow/$${parse_time(\"yyyy/MM/dd/HH\", timestamp(), \"UTC\")}/$${topic(3)}-$${timestamp()}.json"
  }
}
