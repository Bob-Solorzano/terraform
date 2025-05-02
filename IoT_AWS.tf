resource "aws_iot_thing" "tf_wall_e_thing"{
  name = "WALL-E"
}

resource "aws_iot_certificate" "tf_iot_cert" {
  active = true
}

resource "aws_iot_policy" "tf_iot_policy" {
  name = "tf_thing_policy"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iot:Connect",
      "Resource": "arn:aws:iot:us-east-1:640168414211:client/$${iot:Connection.Thing.ThingName}"
    },
    {
      "Effect": "Allow",
      "Action": "iot:Subscribe",
      "Resource": "arn:aws:iot:us-east-1:640168414211:client/$${iot:Connection.Thing.ThingName}"
    },
    {
      "Effect": "Allow",
      "Action": "iot:Receive",
      "Resource": "arn:aws:iot:us-east-1:640168414211:client/$${iot:Connection.Thing.ThingName}"
    },
    {
      "Effect": "Allow",
      "Action": "iot:Publish",
      "Resource": "arn:aws:iot:us-east-1:640168414211:topic/$${iot:Connection.Thing.ThingName}*"
    }
  ]
})
}

resource "aws_iot_policy_attachment" "tf_cert_policy_attach" {
  policy = aws_iot_policy.tf_iot_policy.name
  target = aws_iot_certificate.tf_iot_cert.arn
}

resource "aws_iot_thing_principal_attachment" "thing_cert_attach" {
  principal = aws_iot_certificate.tf_iot_cert.arn
  thing     = aws_iot_thing.tf_wall_e_thing.name
}

resource "aws_dynamodb_table" "tf-iot-dynamodb-table" {
  name           = "IoTLocation"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "sample_time"
  range_key      = "device_id"

    attribute {
    name = "sample_time"
    type = "S"
  }

  attribute {
    name = "device_id"
    type = "S"
  }
}

resource "aws_iot_topic_rule" "tf_iot_rule" {
  name        = "IoTLocationRule"
  description = "IoT Device Locations rule"
  enabled     = true
  sql         = "SELECT sample_time, device_id, sensor, direction, forward_pitch, side_pitch, curr_lat, curr_long, target_lat, target_long FROM 'WALL-E/location'"
  sql_version = "2016-03-23"

  dynamodb {
    hash_key_field = "sample_time"
    hash_key_type = "STRING"
    hash_key_value = file("sample_time.txt")
    range_key_field = "device_id"
    range_key_type = "STRING"
    range_key_value = "device_id"
    role_arn       = aws_iam_role.tf_iot_role.arn
    table_name     = aws_dynamodb_table.tf-iot-dynamodb-table.name
  }

}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "tf_iot_role" {
  name               = "iot_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "iotpolicy" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.tf-iot-dynamodb-table.arn]
  }
}

resource "aws_iam_role_policy" "mypolicy" {
  name   = "mypolicy"
  role   = aws_iam_role.tf_iot_role.id
  policy = data.aws_iam_policy_document.iotpolicy.json
}



resource "aws_iam_role" "tf_iot_s3_role" {
  name               = "iot_s3_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "iots3policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = [aws_s3_bucket.tf_s3_bucket_iot_power.arn]
  }
}

resource "aws_iam_role_policy" "mys3policy" {
  name   = "mys3policy"
  role   = aws_iam_role.tf_iot_s3_role.id
  policy =     data.aws_iam_policy_document.iots3policy.json
}

resource "aws_s3_bucket_public_access_block" "s3_iot_block_public" {
  bucket = aws_s3_bucket.tf_s3_bucket_iot_power.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "iot_power_policy" {
  bucket        = aws_s3_bucket.tf_s3_bucket_iot_power.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Principal = "*"
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::iotpowerbucket/*"]
      }
    ]
  })
}


resource "aws_s3_bucket" "tf_s3_bucket_iot_power" {
  bucket = "iotpowerbucket"

  force_destroy = true

  tags = {
    Name        = "IoT Power Data S3 Bucket"
    Environment = "Dev"
  }
}

resource "aws_iot_topic_rule" "tf_iot_battery_rule" {
  name        = "IoTS3BatteryRule"
  description = "IoT Device Battery rule"
  enabled     = true
  sql         = "SELECT sample_time, device_id, sensor, current, voltage, temperature FROM 'WALL-E/battery'"
  sql_version = "2016-03-23"

  s3 {
    bucket_name = aws_s3_bucket.tf_s3_bucket_iot_power.id
    key = file("bat_timestamp.txt")
    role_arn       = aws_iam_role.tf_iot_s3_role.arn
  }

}