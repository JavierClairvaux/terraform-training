//provider "aws"{
//	region = "us-east-2"
//}

resource "aws_launch_configuration" "example" {
  //image_id = "ami-0998bf58313ab53da"
	image_id = "ami-0fc20dd1da406780b"
  instance_type = var.instance_type 
  security_groups = [aws_security_group.instance.id]
	key_name = "drone-master"
  user_data = data.template_file.user_data.rendered 
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
	}
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port = var.server_port 
  to_port = var.server_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port = 22 
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.instance.id
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_autoscaling_group" "example" {

  launch_configuration = aws_launch_configuration.example.id

  //availability_zones = ["${data.aws_availability_zones.all.names}"]
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
	load_balancers = [aws_elb.example.name]

	min_size = var.min_size
	max_size = var.max_size

	tag {
		key = "Name"
		value = var.cluster_name
		propagate_at_launch = true
	}

	depends_on = [aws_launch_configuration.example]
}



resource "aws_security_group" "elb" {
  name = "${var.cluster_name}-elb"
}

resource "aws_security_group_rule" "allow_elb_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.elb.id
  from_port = 80 
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_elb_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.elb.id
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_elb" "example" {

  name = "${var.cluster_name}-asg"
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  security_groups = [aws_security_group.elb.id]
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = var.server_port
    instance_protocol = "http"
  }
  
	health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }
}

data "aws_availability_zones" "all" {}

data "terraform_remote_state" "db"{
	backend = "s3"
	config = {
		bucket = "javier-c-terraform-state"
    region  = "us-east-2"
    key = var.db_remote_state_key 
  }
}
