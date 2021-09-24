variable "vpc_id" {
  description = "Enter vpc ID"
}

variable "vpc_cidr" {
  description = "vpc's cidr block for SG restriction"
}


variable "private_subnets" {
  description = "Enter private_subnes"
}

variable "env" {
  description = "Enter env"
}
variable "locationcode" {
  description = "Enter locationcode"
}

variable "deployment_id" {
  description = "Enter deployment-id"
}

variable "application_container_port" {
  default = 8000
  description = "Target group port"
}

variable "created_by"{
    description = "Pls specify the user"
    default = "unknown"
}

variable "app_module"{
    default = "load_balancer"
}