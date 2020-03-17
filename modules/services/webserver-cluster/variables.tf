variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
}

variable "server_port" {
  description = "The maximum number of EC2 Instances in the ASG"
}

variable "db_remote_state_key" {
  description = "The maximum number of EC2 Instances in the ASG"
}
