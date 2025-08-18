variable "app_name" {
  type = string
  description = "The name of the application, used for naming resources."
  default = "alma-item-checks"
}

variable "asp_resource_group_name" {
  type = string
}

variable "app_service_plan_name" {
    type = string
}
