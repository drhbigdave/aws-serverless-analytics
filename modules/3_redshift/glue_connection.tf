resource "aws_glue_connection" "redshift_connection" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${aws_redshift_cluster.redshift_cluster.endpoint}/${var.db_name}"
    PASSWORD            = "${data.aws_ssm_parameter.db_pw.value}"
    USERNAME            = "${data.aws_ssm_parameter.db_master.value}"
  }

  name = "${var.db_name}_connection"

  physical_connection_requirements {
    availability_zone      = "${var.availability_zone}"
    security_group_id_list = ["${aws_security_group.redshift.id}"]
    subnet_id              = "${var.subnet}"
  }
}