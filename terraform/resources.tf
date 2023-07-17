# Creacion del resource_group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_name
}

# Creación del container registry
resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.registry_sku
  admin_enabled       = true
}

# Creacaión de la red virtual
resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Creacion de la subred
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Solicitando una Ip pública
resource "azurerm_public_ip" "pip" {
  name                = "VIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "domaintest"  
}

# Creando el security group
resource "azurerm_network_security_group" "sg"{
  name                = "vsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  ="Inbound"
    access                     ="Allow"
    protocol                   ="Tcp"
    source_port_range          ="*"
    destination_port_range     ="22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  ="Inbound"
    access                     ="Allow"
    protocol                   ="Tcp"
    source_port_range          ="*"
    destination_port_range     ="80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags={
    environment ="Test"
  }
}

# Asociando a la subred el security group
resource "azurerm_subnet_network_security_group_association" "ngs-link" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

# Creando el interface de red y asignandole la subred y la ip pública
resource "azurerm_network_interface" "nic" {
  name                = "vnic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
    
  }
}

# Creando y mostrando la clave SSH
resource "tls_private_key" "claves_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Asignando al interface de red el security group
resource "azurerm_network_interface_security_group_association" "nicgs"{
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

# Creando el AKS
#resource "azurerm_kubernetes_cluster" "aksjrng76"{
#  name                = "aks-aksjrng76"
#  location            = azurerm_resource_group.rg.location
#  resource_group_name = azurerm_resource_group.rg.name
#  dns_prefix          = "jrng76"

#  default_node_pool {
#    name = "default"
#    node_count =1
#    vm_size = "Standard_D2_V2"
#  }

#  identity {
#    type = "SystemAssigned"  
#  }
#}

# Vinculando el Acr al Aks
#resource "azurerm_role_assignment" "acraks" {
#  principal_id                     = azurerm_kubernetes_cluster.aksjrng76.kubelet_identity[0].object_id
#  role_definition_name             = "AcrPull"
#  scope                            = azurerm_container_registry.acr.id
#  skip_service_principal_aad_check = true
#}

# Creando la maquina virtual 
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = var.ssh_user
  computer_name       = "vmcentos01"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = tls_private_key.claves_ssh.public_key_openssh
    #public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
}
