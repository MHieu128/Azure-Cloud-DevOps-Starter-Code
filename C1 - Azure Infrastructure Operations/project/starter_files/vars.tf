variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "az-devops-testing"
}

variable "location" {
  description = "The Azure region in which all resources in this example should be created"
  default     = "East US"
}

variable "instance_count" {
  description = "Number machines when this example created"
  type        = number
  default     = 2
}

variable "packer_resource_group" {
  description = "Resource group of the Packer image"
  default     = "az-devops-rg"
}

variable "packer_image_name" {
  description = "Image name of the Packer image"
  default     = "my-packer-image"
}
