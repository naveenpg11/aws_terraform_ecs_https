
variable "region" {
  description = "Region"
}
variable "env" {
  description = "Environment"
}
variable "locationcode" {
  description = "Location Accronym. Used to comply naming convention"
  type        = map(any)
  default = {
    us-east-1  = "use"
    us-west-2  = "usw"
    ap-south-1 = "aps"
    us-east-2 = "use2"
  }
}
variable "cidrange" {
  description = "set the cidr range for vpc "
}
variable "az1" {
  description = "availability zone 1"
}

variable "az2" {
  description = "availability zone 2"
}

variable "public-subnet-1-block" {
  description = "public subnet 1 cidr"
}

variable "public-subnet-2-block" {
  description = "public subnet 2 cidr"
}

variable "private-subnet-1-block" {
  description = "private subnet 1 cidr"
}


variable "private-subnet-2-block" {
  description = "private subnet 2 cidr"
}

variable "deployment_id" {
  description = "Deployment id"
}


variable "container_image_id" {
  description = "Container IMage ID"
}

variable "created_by" {
  description = "resource created by"
}

variable "application_container_port" {
  description = "application_container_port"
}