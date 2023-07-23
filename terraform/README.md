# Despliegue de la infraestructura con Terraform

## Script execterraform.sh
Para facilitar el despliegue con **terraform** se ha creado un script llamado execterraform.sh que realiza las siguientes acciones:
  - Creación del plan llamado 'MyPlan'.
    ```bash  
    terraform plan -out "MyPlan"
    ```
  - Aplicar el plan construido para crear la infraestructura.
    ```bash  
    terraform apply "MyPlan"
    ```
  - Copiar la clave privada generada por terraform al directorio de **ansible** para  validarse contra la maquina virtual creada y cambiar sus permisos de acceso.
    ```bash  
    terraform output -raw tls_private_key > ../ansible/id_rsa_vm
    chmod 600 ../ansible/id_rsa_vm
    ```  
  - Mostrar las variables de salida de nuevo. 
    ```bash  
    terraform refresh
    ```  
  - Crear el fichero inventary con la ip pública de la vm que luego usará **ansible**. 
    ```bash  
    echo "[hosts]" > ../ansible/inventary
    terraform output public_ip_address >> ../ansible/inventary
    ```  
  - Crear el fichero vars.yaml con las variables del acr  (user, password y login server) creado por **terraform** y que luego las utilizará **ansible** 
    ```bash  
    echo "acr_user: $(terraform output acr_admin_user)" > ../ansible/vars.yaml
    echo "acr_pass: $(terraform output acr_admin_pass)" >> ../ansible/vars.yaml
    echo "acr_server: $(terraform output acr_login_server)" >> ../ansible/vars.yaml
    echo "acr_server_nginx: $(terraform output acr_login_server)/nginx" | sed -r 's/["]//g' >> ../ansible/vars.yaml
    echo "acr_server_mysql: $(terraform output acr_login_server)/mysql" | sed -r 's/["]//g' >> ../ansible/vars.yaml
    echo "acr_server_phpmyadmin: $(terraform output acr_login_server)/phpmyadmin" | sed -r 's/["]//g' >> ../ansible/vars.yaml
    ```
## Fichero main.tf
Fichero de configuración del proveedor de Azure para terraform.
```bash
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.10.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}
```
## Fichero resources.tf
El fichero resources.tf contiene la infraestructura a crear en Azure:
  - Resource Group.
  - Container Registry.
  - Virtual Network.
  - Subnet.
  - Ip Public.
  - Security Group.
    - Security rule port 22.
    - Security rule port 80.
    - Security rule port 443
  - Asociar a la Subnet el Security Group.
  - Network Interface.
  - Creación de par de claves ssh.
  - Creación de una máquina virtual.
    - 2 cpu virtuales y 4 GiB de Ram.
    - S.O. CentOs 8
  - Azure Container Registry (ACR). Como repositorio de las imágenes que se usarán en la solución.
  - Azure Kubernetes Service (AKS).
  - Vincular el ACR al AKS para que tenga acceso a las imágenes del repositorio.

## Fichero variables.tf
En el fichero variables.tf están definidas las variables.
- resource_group_name. Nombre del resource group.
- location_name. Localización de la zona.
- network_name. Nombre de la red.
- subnet_name. Nombre de la subred.
- ssh_user. Usuario ssh.
- registry_name. Nombre del acr.
- registry_sku. Tipo de SKU a utilizar por el registry.

## Fichero outputs.tf
Fichero con las variables de salida:
- resource_group_id. Identificador del grupo de recursos.
- vm_id. Identificador de la máquina virtual creada.
- sg_id. Identificador del grupo de seguridad.
- public_ip_address. Dirección Ip pública de acceso a la máquina virtual.
- tls_private_key. Clave privada.
- acr_login_server. Logín de servidor acr.
- acr_admin_user. Usuario administrador del acr.
- acr_admin_pass. Contraseña del usuario administrador del acr.
- ssh_user. Usuario para la conexión con ssh.
- client_certificate. Certificado cliente del AKS.
- kube_config. Configuración del AKS.