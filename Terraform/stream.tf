#  Politica criada para o s3 e stream
resource "aws_iam_role_policy" "kinesis_stream_policy" {
  name = "KinesisFirehoseServicePolicy"
  role = "${aws_iam_role.kinesis_stream_roles.id}"

  policy = "${file("json/policy_stream.json")}"
}

resource "aws_iam_role" "kinesis_stream_roles" {
  name = "KinesisFirehoseServiceRole"

  assume_role_policy = "${file("json/kinesis.json")}"
}

# S3 que o stram Firehose encaminha os dados extraidos
resource "aws_s3_bucket" "bucket_windfarm" {
  bucket        = "asabranca-windfarm-kinesis"
  force_destroy = true
}
# ACL do s3
resource "aws_s3_bucket_acl" "bucket_windfarm_acl" {
  bucket = aws_s3_bucket.bucket_windfarm.id
  acl    = "private"
}

# Stream Vinculado ao código produtores
resource "aws_kinesis_stream" "windfarm" {
  name                      = "kinessi_terraform"
  shard_count               = 1
  retention_period          = 24
  enforce_consumer_deletion = true # Força delete dos arquivos

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "windfarm_delivery" {
  name = "terraform-kinesis-to-bucket-windfarm"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_stream_roles.arn
    bucket_arn = aws_s3_bucket.bucket_windfarm.arn
    buffer_interval = 60

  }

  kinesis_source_configuration {
    role_arn = aws_iam_role.kinesis_stream_roles.arn
    kinesis_stream_arn = aws_kinesis_stream.windfarm.arn
  }

}