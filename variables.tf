variable "rg" {
    description = "The name of the resource group in which to create the communication service."
    default = "rg-acs"
}
variable "location" {
    description = "The Azure Region in which all resources in this example should be created."
    default = "West Europe"
}
variable "data_location" {
    description = "The location of the data."
    default = "Europe"
}
