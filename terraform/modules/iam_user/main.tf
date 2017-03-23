variable "name" {
  description = "IAM user name"
}

variable "policy" {
  description = "IAM policy to attach to IAM user"
}

resource "aws_iam_user" "iam-user" {
  name = "${var.name}"
}

resource "aws_iam_access_key" "iam-user" {
  user = "${aws_iam_user.iam-user.name}"
}

resource "aws_iam_user_policy" "iam-user" {
  name   = "${aws_iam_user.iam-user.name}-policy"
  user   = "${aws_iam_user.iam-user.name}"
  policy = "${var.policy}"
}

output "name" {
  sensitive = true
  value     = "${aws_iam_access_key.iam-user.name}"
}

output "id" {
  sensitive = true
  value     = "${aws_iam_access_key.iam-user.id}"
}

output "secret" {
  sensitive = true
  value     = "${aws_iam_access_key.iam-user.secret}"
}
