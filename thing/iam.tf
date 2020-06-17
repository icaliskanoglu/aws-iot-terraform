data "aws_iam_policy_document" "thing-service-policy-document" {
  version = "2012-10-17"
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.thing-deployment-bucket.bucket}",
    ]
  }
  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.thing-deployment-bucket.bucket}/thing/${var.thing_group}/*",
    ]
  }
}
resource "aws_iam_policy" "thing-service-policy" {
  name = "${var.thing_group}-service-policy"
  policy = "${data.aws_iam_policy_document.thing-service-policy-document.json}"
}

resource "aws_iam_role" "thing-service-role" {
  name = "${var.thing_group}-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "credentials.iot.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "1"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "thing-service-role-attachment" {
  role       = "${aws_iam_role.thing-service-role.name}"
  policy_arn = "${aws_iam_policy.thing-service-policy.arn}"
}

resource "aws_iot_role_alias" "thing-service-role-alias" {
  alias    = "${var.thing_group}-service-role-alias"
  role_arn = "${aws_iam_role.thing-service-role.arn}"
}


data "aws_iam_policy_document" "thing-deploy-policy-document" {
  version = "2012-10-17"
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.thing-deployment-bucket.bucket}/thing/${var.thing_group}/*",
      "arn:aws:s3:::${aws_s3_bucket.thing-deployment-bucket.bucket}/thing/common/*"
    ]
  }
  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      #"iot:Describe*",
      #"iot:List*",
      "iot:*",
    ]
    resources = [
      "arn:aws:iot:::*",
    ]
  }
}

resource "aws_iam_policy" "thing-deploy-policy" {
  name = "${var.thing_group}-deploy-policy"
  policy = "${data.aws_iam_policy_document.thing-deploy-policy-document.json}"
}

resource "aws_iam_role" "thing-deploy-role" {
  name = "${var.thing_group}-deploy-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "1"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "thing-deploy-role-policy-attachment" {
  role       = "${aws_iam_role.thing-deploy-role.name}"
  policy_arn = "${aws_iam_policy.thing-deploy-policy.arn}"
}

resource "aws_iam_user" "thing-deploy-user" {
  name = "${var.thing_group}-deploy-user"
}

resource "aws_iam_user_policy_attachment" "thing-deploy-user-policy-attachment" {
  policy_arn = "${aws_iam_policy.thing-deploy-policy.arn}"
  user = "${aws_iam_user.thing-deploy-user.name}"
}


data "aws_iam_policy_document" "thing-shadow-rule-policy-document" {
  version = "2012-10-17"
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.thing-shadow-bucket.bucket}",
    ]
  }
  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "s3:Put*",
      "s3:Get*",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.thing-shadow-bucket.bucket}/things/shadow/*",
    ]
  }
}
resource "aws_iam_policy" "thing-shadow-rule-policy" {
  name = "thing-shadow-rule-policy"
  policy = "${data.aws_iam_policy_document.thing-shadow-rule-policy-document.json}"
}

resource "aws_iam_role" "thing-shadow-rule-role" {
  name = "thing-shadow-rule-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "1"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "thing-shadow-rule-role-attachment" {
  role       = "${aws_iam_role.thing-shadow-rule-role.name}"
  policy_arn = "${aws_iam_policy.thing-shadow-rule-policy.arn}"
}