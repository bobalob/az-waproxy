resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Create virtual network
resource "azurerm_virtual_network" "waproxy_vnet" {
  name                = "waproxynet"
  address_space       = ["10.50.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "waproxy_subnet" {
  name                 = "waproxysubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.waproxy_vnet.name
  address_prefixes     = ["10.50.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "waproxy_public_ip" {
  name                = "${var.virtual_machine_name}-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = var.dns_prefix
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "waproxy_nsg" {
  name                = "${var.virtual_machine_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
      name                       = "SSH"
      priority                   = 401
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 22
      source_address_prefix      = var.management_range
      destination_address_prefix = "*"
  }
  security_rule {
      name                       = "HTTP"
      priority                   = 402
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 80
      source_address_prefix      = "*"
      destination_address_prefix = "*"
  }
  security_rule {
      name                       = "HTTPS"
      priority                   = 403
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 443
      source_address_prefix      = "*"
      destination_address_prefix = "*"
  }
  security_rule {
      name                       = "Jabber"
      priority                   = 404
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 5222
      source_address_prefix      = "*"
      destination_address_prefix = "*"
  }
  security_rule {
      name                       = "HTTP_Proxy"
      priority                   = 405
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 8080
      source_address_prefix      = "*"
      destination_address_prefix = "*"
  }
  security_rule {
      name                       = "HTTPS_Proxy"
      priority                   = 406
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 8443
      source_address_prefix      = "*"
      destination_address_prefix = "*"
  }
  security_rule {
      name                       = "Jabber_Proxy"
      priority                   = 407
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 8222
      source_address_prefix      = "*"
      destination_address_prefix = "*"
  }
  security_rule {
      name                       = "HAProxy_Stats"
      priority                   = 408
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 8199
      source_address_prefix      = var.management_range
      destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "waproxy_nic" {
  name                = "${var.virtual_machine_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.virtual_machine_name}-ipconf"
    subnet_id                     = azurerm_subnet.waproxy_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.waproxy_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.waproxy_nic.id
  network_security_group_id = azurerm_network_security_group.waproxy_nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create (and display) an SSH key
#resource "tls_private_key" "example_ssh" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "waproxy_vm" {
  name                  = var.virtual_machine_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.waproxy_nic.id]
  size                  = var.machine_sku

  os_disk {
    name                 = "${var.virtual_machine_name}-osDisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name                   = var.virtual_machine_name
  admin_username                  = var.username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.username
    #public_key = tls_private_key.example_ssh.public_key_openssh
    public_key = var.ssh_public_key
  }

  boot_diagnostics {
    storage_account_uri = null
    #storage_account_uri = azurerm_storage_account.waproxy_sa.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "vmext" {
    name                  = "${var.virtual_machine_name}-vmext"
    virtual_machine_id    = azurerm_linux_virtual_machine.waproxy_vm.id

    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    protected_settings = <<PROT
    {
        "script": "${base64encode(file(var.build_script))}"
    }
    PROT
}
