variable "vpc_id" {
  description = "Enter vpc ID"
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

variable "created_by"{
    description = "Pls specify the user"
    default = "unknown"
}

variable "app_module"{
    default = "api_gateway"
}

variable "alb_listener_arn" {
  description = "Specify TG's Arn"
}