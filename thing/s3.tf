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

resource "aws_s3_bucket" "thing-shadow-bucket" {
  bucket = "${var.organization_name}-thing-shadow-${data.aws_region.current.name}"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name = "${var.organization_name}-thing-shadow-${data.aws_region.current.name}"
  }
}


resource "aws_glue_catalog_database" "thing-shadow-database" {
  name = "${var.organization_name}_thing_shadow_database"
}

resource "aws_glue_catalog_table" "thing-shadow-table" {
  name          = "${var.organization_name}_thing_shadow_table"
  database_name = "${aws_glue_catalog_database.thing-shadow-database.name}"

  table_type = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.thing-shadow-bucket.bucket}/things/shadow/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
      name= "thing_shadow_serde"
    }

    columns {
      name = "thingname"
      type = "string"
    }

    columns {
      name    = "state"
      type    = "struct<reported:struct<onstart:struct<resetreason:string,chipid:int,cpufreqmhz:int,sketchmd5:string,coreversion:string,sdkversion:string,flashchiprealsize:int,flashchipsize:int>,onloop:struct<analogpinoutputvalue:int,analogpina0:int,vcc:double>>>"
    }
  }
}
