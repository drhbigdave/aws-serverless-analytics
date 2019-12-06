resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "log_bucket_1" {
  bucket = "${var.log_bucket_1}"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "bucket_1" {
  bucket = "${var.bucket_1_name}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.mykey.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
  logging {
    target_bucket = "${aws_s3_bucket.log_bucket_1.id}"
    target_prefix = "CityData/"
  }
  tags = {
    Name        = "${var.bucket_1_name}"
    Training = "Udemy"
  }
}
##below was an exploration and attempt to turn on analytics, it is still an open
##request on the provider github issues page
resource "aws_s3_bucket_metric" "citydata-filtered" {
  bucket = "${aws_s3_bucket.bucket_1.bucket}"
  name   = "UdemyCityData"
  filter {
    prefix = "CityData/"
    tags = {
      priority = "high"
      class    = "blue"
}
  }
}
