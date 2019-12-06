module "s3" {

  source        = "../../modules/2_s3/"
  log_bucket_1  = "drh-udemy-logging"
  bucket_1_name = "drh-udemy-city-data"

  #  path_to_privkey    = "~/projects/tf_keys/spark-mykey"
  #  path_to_pubkey     = "~/projects/tf_keys/spark-mykey.pub"
  #  subnet_pub    = "${module.network.external_subnet_output}"
  #  subnet_priv    = "${module.network.internal_subnet_output}"
  #  redshift_cluster_endpoint = "${element(split(":", module.redshift.redshift_endpoint),0)}"
  #  redshift_db_name = "${module.redshift.redshift_db_name}"
  #  redshift_port = "${module.redshift.redshift_port}"
}
module "redshift" {
  source            = "../../modules/3_redshift/"
  cluster_name      = "redshift1"
  db_name           = "redshiftdb"
  node_type         = "dc2.large"
  cluster_type      = "multi-node"
  nodes             = 2
  subnet_group_name = "group1"
  enhanced          = true
  iam_roles         = "udemy_pipeline"
  final_snap        = true
  subnet            = "${module.network.external_subnet_output}"
  availability_zone = "us-east-1a" #improve
  #  master_sg         = "${module.cloudera.cloudera_sg_priv_output}"
}
module "network" {
  source            = "../../modules/1_network"
  availability_zone = "us-east-1f"
}
output "endpoint_var" {
  value = "substr(${module.redshift.redshift_endpoint},0, -5)"
}
