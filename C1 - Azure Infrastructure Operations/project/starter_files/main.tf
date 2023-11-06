terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vmss" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_network_security_group" "vmss" {
  name                = "${var.prefix}-security"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name
}

resource "azurerm_virtual_network" "vmss" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "testing"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.vmss.name
  virtual_network_name = azurerm_virtual_network.vmss.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_public_ip" "vmss" {
  name                = "acceptance${var.prefix}PublicIp1"
  resource_group_name = azurerm_resource_group.vmss.name
  location            = azurerm_resource_group.vmss.location
  allocation_method   = "Static"

  tags = {
    environment = "testing"
  }
}

resource "azurerm_lb" "vmss" {
  name                = "${var.prefix}LoadBalancer"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss.id
  }
}

data "azurerm_resource_group" "image" {
  name = var.packer_resource_group
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_availability_set" "vmss" {
  name                = "${var.prefix}-aset"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "vmss" {
  count               = var.instance_count
  name                = "${var.prefix}-nic-${count.index}"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vmss" {
  count                 = var.instance_count
  name                  = "${var.prefix}-virtualmachine-${count.index}"
  location              = azurerm_resource_group.vmss.location
  resource_group_name   = azurerm_resource_group.vmss.name
  network_interface_ids = [element(azurerm_network_interface.vmss.*.id, count.index)]
  vm_size               = "Standard_F2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "terradisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "nflinux"
    admin_username = "nfadmin"
    admin_password = "Admin12345@"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "testing"
  }
}
