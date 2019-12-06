data "aws_ssm_parameter" "db_pw" {
  name = "redshift_pw"
}

output "db_pw_string" {
  value = "${data.aws_ssm_parameter.db_pw.value}"
}
data "aws_ssm_parameter" "db_master" {
  name = "redshift_master"
}

output "db_master_string" {
  value = "${data.aws_ssm_parameter.db_master.value}"
}

data "aws_iam_role" "redshift_role" {
  name = "${var.iam_roles}"
}

output "redshift_role" {
  value = "${data.aws_iam_role.redshift_role.arn}"
}

resource "aws_redshift_cluster" "redshift_cluster" {
  #  count              = "${var.count}" #use of requires splat notation, makes a list
  cluster_identifier        = "${var.cluster_name}"
  database_name             = "${var.db_name}"
  master_username           = "${data.aws_ssm_parameter.db_master.value}"
  master_password           = "${data.aws_ssm_parameter.db_pw.value}"
  node_type                 = "${var.node_type}"
  cluster_type              = "${var.cluster_type}"
  number_of_nodes           = "${var.nodes}"
  cluster_subnet_group_name = "${aws_redshift_subnet_group.redshift_subnet_group1.name}"
  enhanced_vpc_routing      = "${var.enhanced}"
  iam_roles                 = ["${data.aws_iam_role.redshift_role.arn}"]
  vpc_security_group_ids    = ["${aws_security_group.redshift.id}"]
  skip_final_snapshot       = "${var.final_snap}"
  #  depends_on          = ["${aws_internet_gateway.internet_gw.id}"]
}
output "redshift_endpoint" {
  value = "${aws_redshift_cluster.redshift_cluster.endpoint}"
}
output "redshift_db_name" {
  value = "${aws_redshift_cluster.redshift_cluster.database_name}"
}
output "redshift_port" {
  value = "${aws_redshift_cluster.redshift_cluster.port}"
}
