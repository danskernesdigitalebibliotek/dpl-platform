variable "base_domain" {
  description = "The base domain to use when creating a *.<environment>.dpl.<base_domain> wilcard record for the setup."
  type        = string
  default     = "reload.dk"
}

variable "environment_name" {
  description = "Lowercased alpha-numeric name to use to identify the environment. As the name is used in resource-names its advicable to keep it short."
  type        = string
}

variable "location" {
  description = "The Azure location to use for the environment"
  type        = string
}

variable "node_pool_system_count" {
  description = "The number of nodes in the system node-pool"
  default     = 1
  type        = number
}

variable "node_pool_system_vm_sku" {
  description = "The SKU of the virtual machines used for the system nodepool"
  default     = "Standard_B4ms"
  type        = string
}

variable "random_seed" {
  description = "Any random value used to seed the random parts of the provisioned resources"
  type        = string
}

variable "sql_sku" {
  description = "The SKU used for MariaDB"
  type        = string
  default     = "GP_Gen5_2"
}

variable "sql_version" {
  description = "The version of MariaDB to request from Azure"
  type        = string
  default     = "10.2"
}

variable "sql_storage_mb" {
  description = "Amount of storage to request for the MariaDB services"
  type        = number
  default     = 5120
}
