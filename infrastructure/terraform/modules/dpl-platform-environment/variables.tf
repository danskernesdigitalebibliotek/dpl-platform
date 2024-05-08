variable "base_domain" {
  description = "The base domain to use when creating a *.<environment>.dpl.<base_domain> wilcard record for the setup."
  type        = string
  default     = "reload.dk"
}

variable "control_plane_version" {
  description = "Which version of the AKS control-plane to provision. Bump this variable to trigger an upgrade."
  type        = string
}

variable "domain_ttl" {
  description = "The Time To Live for the provisioned domains."
  type        = number
  default     = 43200
}

variable "lagoon_domain_base" {
  description = "Base domain to use for lagoon hostnames"
  type        = string
}

variable "environment_name" {
  description = "Lowercased alpha-numeric name to use to identify the environment. As the name is used in resource-names its advicable to keep it short."
  type        = string
}

variable "location" {
  description = "The Azure location to use for the environment"
  type        = string
  default     = "West Europe"
}

variable "node_pool_admin_count_max" {
  description = "The maximum number of pods to autoscale the administration nodepool to"
  default     = 6
  type        = number
}

variable "node_pool_admin_count_min" {
  description = "The minimum number of pods to autoscale the administration nodepool to, also used as the initial count for the nodepool"
  default     = 3
  type        = number
}

variable "node_pool_admin_vm_sku" {
  description = "The SKU of the virtual machines used for the administration nodepool"
  default     = "Standard_B4ms"
  type        = string
}

variable "node_pool_app_default_count_max" {
  description = "The maximum number of pods to autoscale the default application nodepool to"
  default     = 3
  type        = number
}

variable "node_pool_app_default_count_min" {
  description = "The minimum number of pods to autoscale the default application nodepool to, also used as the initial count for the nodepool"
  default     = 1
  type        = number
}

variable "node_pool_app_default_vm_sku" {
  description = "The SKU of the virtual machines used for the default application nodepool"
  default     = "Standard_B4ms"
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
  default     = "10.3"
}

variable "sql_storage_mb" {
  description = "Amount of storage to request for the MariaDB services. Be aware that the number of IOPS you get scales with the storage size. 100GB will give you 300IOPS, every additional GB gives you 3 IOPS"
  type        = number
  default     = 102400
}
