# Create an Azure resource group:

resource "azurerm_resource_group" "rg" {
  name     = "resource_group-${var.app}-${var.env}"
  location = var.RG-location
  tags = {
    Environment = var.env
    Application = var.app
  }
}

# Create a virtual network:
resource "azurerm_virtual_network" "vnet" {
  name                = "VNet-${var.app}-${var.env}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Environment = var.env
    Application = var.app
  }
}

#  Create a subnet for application

resource "azurerm_subnet" "subnet01" {
  name                 = "web-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}
# create UDR for the subnet01

resource "azurerm_route_table" "route_table" {
  name                = "UDR-${var.app}-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "web-routing"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"

  }
}

resource "azurerm_subnet_route_table_association" "route_table_association" {
  subnet_id      = azurerm_subnet.subnet01.id
  route_table_id = azurerm_route_table.route_table.id
}

#  create NSG rule to allow inbound traffic
resource "azurerm_network_security_group" "nsg01" {
  name                = "NSG-${var.app}-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "in-http" {
  name                         = "in-http"
  priority                     = 1500
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "80"
  source_address_prefix        = "*"
  destination_address_prefixes = azurerm_subnet.subnet01.address_prefixes
  resource_group_name          = azurerm_resource_group.rg.name
  network_security_group_name  = azurerm_network_security_group.nsg01.name
}

resource "azurerm_network_security_rule" "in-https" {
  name                        = "in-https"
  priority                    = 1400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg01.name
}

resource "azurerm_network_security_rule" "in-ssh" {
  name                         = "rule-ssh"
  priority                     = 1700
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "22"
  source_address_prefix        = "*"
  destination_address_prefixes = azurerm_subnet.subnet01.address_prefixes
  resource_group_name          = azurerm_resource_group.rg.name
  network_security_group_name  = azurerm_network_security_group.nsg01.name
}

resource "azurerm_network_security_rule" "out-http" {
  name                        = "out-http"
  priority                    = 1500
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg01.name
}

resource "azurerm_network_security_rule" "out-https" {
  name                        = "out-https"
  priority                    = 1400
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg01.name
}

resource "azurerm_subnet_network_security_group_association" "subnet01_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet01.id
  network_security_group_id = azurerm_network_security_group.nsg01.id
}


# subnet for Backend server

resource "azurerm_subnet" "subnet02" {
  name                 = "Middleware"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnet03" {
  name                 = "Application-Gateway"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "subnet04" {
  name                 = "private-endpoint"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}
