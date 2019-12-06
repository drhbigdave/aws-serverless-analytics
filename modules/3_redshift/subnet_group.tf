resource "aws_redshift_subnet_group" "redshift_subnet_group1" {
  name       = "${var.subnet_group_name}"
  subnet_ids = ["${var.subnet}"]
}

output "redshift_subnet_group_1" {
  value = "${aws_redshift_subnet_group.redshift_subnet_group1.name}"
}