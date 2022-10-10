#######################
# resource group conf
#######################
variable "rg_name" {
  description = "The name of the resource group in which to create the communication service."
  default     = "rg-acs"
}

variable "create_rg" {
  description = "Create a resource group?"
  default     = true
}

#######################
# general conf
#######################
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "West Europe"
}

#######################
# keyvault conf
#######################
variable "kv_name" {
  description = "The name of the key vault in which to create the communication service."
  default     = "kv-acs"
}

variable "kv_rg_name" {
  description = "The name of the resource group in which to create (or find, if existing) the key vault."
  default     = "rg-acs"
}

variable "create_kv" {
  description = "Create a key vault?"
  default     = true
}

variable "byok_name" {
  description = "The name of the key for BYOK, stored inside KeyVault."
  default     = "byok-acs"
}

variable "enable_kv_logs_to_loganalytics" {
  description = "Enable KeyVault logs to log analytics?"
  default     = true
}

#######################
# managed identity conf
#######################
variable "mi_name" {
  description = "The name of the managed identity to create."
  default     = "mi-acs"
}

variable "mi_rg_name" {
  description = "The name of the resource group in which to create (or find, if existing) the managed identity."
  default     = "rg-acs"
}

variable "create_mi" {
  description = "Create a managed identity?"
  default     = true
}

#######################
# storage account conf
#######################
variable "sa_name" {
  description = "The name of the storage account in which to create dead letter."
  default     = "sadeadletter"
}

variable "sa_replication_type" {
  description = "The type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS and ZRS."
  default     = "GZRS"
}

variable "sa_tier" {
  description = "The tier of this storage account. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "enable_sa_logs_to_loganalytics" {
  description = "Enable storage account logs to log analytics?"
  default     = true
}

#######################
# acs conf
#######################
variable "acs_name" {
  description = "The name of the communication service."
  default     = "acs"
}

variable "data_location" {
  description = "The location of the data."
  default     = "Europe"
}

variable "enable_acs_logs_to_loganalytics" {
  description = "Enable ACS logs to log analytics?"
  default     = true
}

#######################
# eventhub conf
#######################
variable "eventhub_name" {
  description = "The name of the eventhub namespace."
  default     = "eventhub"
}

variable "eventhubs" {
  description = "Name of eventhubs to create"
  type = map(object({
    name = string
  }))
  default = {
    "interactions" = {
      name                                 = "interactions"
    }
    "recordings" = {
      name                                 = "recordings"
    }
  }
}

variable "eventhub_capacity" {
  description = "The capacity of the eventhub."
  default     = 1
}

variable "eventhub_sku" {
  description = "The sku of the eventhub."
  default     = "Premium" # must be at least premium in order to configure BYOK
}

variable "eventhub_zone_redundant" {
  description = "Is the eventhub zone redundant?"
  default     = true
}

variable "eventhub_partition_count" {
  description = "The partition count of the eventhub."
  default     = 2
}

variable "eventhub_message_retention" {
  description = "The message retention of the eventhub, in days."
  default     = 30
}

variable "enable_eventhub_logs_to_loganalytics" {
  description = "Enable eventhub logs to log analytics?"
  default     = true
}

#######################
# eventgrid conf
#######################
variable "eventgrid_name" {
  description = "The name of the eventgrid."
  default     = "acs-eventgrid"
}

variable "enable_eventgrid_logs_to_loganalytics" {
  description = "Enable eventgrid logs to log analytics?"
  default     = true
}

#######################
# loganalytics conf
#######################
variable "loganalytics_name" {
  description = "The name of the log analytics workspace."
  default     = "acs-loganalytics"
}
variable "loganalytics_sku" {
  description = "The sku of the loganalytics workspace."
  default     = "PerGB2018"
}

variable "loganalytics_retention_in_days" {
  description = "The retention in days of the loganalytics workspace."
  default     = 30
}
