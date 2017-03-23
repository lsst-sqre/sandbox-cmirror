output "CMIRROR_S3_BUCKET" {
  value = "${aws_s3_bucket.cmirror.id}"
}

output "CMIRROR_PUSH_USER" {
  value = "${module.push-user.name}"
}

output "CMIRROR_PUSH_AWS_ACCESS_KEY_ID" {
  sensitive = true
  value     = "${module.push-user.id}"
}

output "CMIRROR_PUSH_AWS_SECRET_ACCESS_KEY" {
  sensitive = true
  value     = "${module.push-user.secret}"
}
