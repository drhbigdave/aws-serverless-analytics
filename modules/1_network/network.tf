data "aws_ssm_parameter" "vpc_id" {
  name = "default_vpc"
}

output "vpc_string" {
  value = "${data.aws_ssm_parameter.vpc_id.value}"
}

data "aws_ssm_parameter" "vpc_s3_endpoint" {
  name = "s3_endpoint"
}

output "vpce_string" {
  value = "${data.aws_ssm_parameter.vpc_s3_endpoint.value}"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${data.aws_ssm_parameter.vpc_id.value}"
  service_name = "com.amazonaws.us-east-1.s3"
}

resource "aws_subnet" "external" {
  vpc_id            = "${data.aws_ssm_parameter.vpc_id.value}"
  cidr_block        = "172.31.17.0/24"
  availability_zone = "${var.availability_zone}"

  tags = {
    Name = "udemy-external"
  }
}

output "external_subnet_output" {
  value = "${aws_subnet.external.id}"
}

resource "aws_internet_gateway" "int_gw" {
  vpc_id = "${data.aws_ssm_parameter.vpc_id.value}"

  tags = {
    Name = "udemy"
  }
}

output "internet_gw" {
  value = "${aws_internet_gateway.int_gw.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.external.id}"
  depends_on    = ["aws_internet_gateway.int_gw"]

  tags = {
    Name = "udemy"
  }
}

resource "aws_subnet" "internal" {
  vpc_id            = "${data.aws_ssm_parameter.vpc_id.value}"
  cidr_block        = "172.31.18.0/24"
  availability_zone = "${var.availability_zone}"

  tags = {
    Name = "udemy-internal"
  }
}

output "internal_subnet_output" {
  value = "${aws_subnet.internal.id}"
}


resource "aws_route_table" "us-east-1a-public" {
  vpc_id = "${data.aws_ssm_parameter.vpc_id.value}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.int_gw.id}"
  }

  tags = {
    Name = "Udemy Public Subnet"
  }
}

resource "aws_route_table_association" "us-east-1a-public" {
  subnet_id      = "${aws_subnet.external.id}"
  route_table_id = "${aws_route_table.us-east-1a-public.id}"
}
resource "aws_vpc_endpoint_route_table_association" "external" {
  route_table_id  = "${aws_route_table.us-east-1a-public.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}

resource "aws_route_table" "us-east-1a-private" {
  vpc_id = "${data.aws_ssm_parameter.vpc_id.value}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }

  tags = {
    Name = "Udemy Private Subnet"
  }
}

resource "aws_route_table_association" "us-east-1a-private" {
  subnet_id      = "${aws_subnet.internal.id}"
  route_table_id = "${aws_route_table.us-east-1a-private.id}"
}

resource "aws_vpc_endpoint_route_table_association" "internal" {
  route_table_id  = "${aws_route_table.us-east-1a-private.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}
