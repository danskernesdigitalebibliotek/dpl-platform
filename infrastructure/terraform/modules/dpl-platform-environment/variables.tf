variable "location" {
  description = "The Azure location to use for the environment"
  type        = string
}

variable "environment_name" {
  description = "Lowercased alpha-numeric name to use to identify the environment. As the name is used in resource-names its advicable to keep it short."
  type        = string
}
