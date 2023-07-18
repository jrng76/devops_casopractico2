# Despliegue de la infraestructura con Terraform

## Script execterraform.sh
Para facilitar el despliegue con **terraform** se ha creado un script llamado execterraform.sh que realiza las siguientes acciones:
  - Creación del plan llamado 'MyPlan'.
    ```  
    terraform apply "MyPlan"
    ```
  - Aplicar el plan construido para crear la infraestructura.
    ```  
    terraform apply "MyPlan"
    ```
  - Copiar la clave privada generada por terraform al directorio de **ansible** para  validarse contra la maquina virtual creada y cambiar sus permisos de acceso.
    ```  
    terraform output -raw tls_private_key > ../ansible/id_rsa_vm
    chmod 600 ../ansible/id_rsa_vm
    ```  
  - Mostrar las variables de salida de nuevo. 
    ```  
    terraform refresh
    ```  
  - Crear el fichero inventary con la ip pública de la vm que luego usará **ansible**. 
    ```  
    echo "[hosts]" > ../ansible/inventary
    terraform output public_ip_address >> ../ansible/inventary
    ```  
  - Crear el fichero vars.yaml con las variables del acr  (user, password y login server) creado por **terraform** y que luego las utilizará **ansible** 
    ```  
    echo "acr_user: $(terraform output acr_admin_user)" > ../ansible/vars.yaml
    echo "acr_pass: $(terraform output acr_admin_pass)" >> ../ansible/vars.yaml
    echo "acr_server: $(terraform output acr_login_server)" >> ../ansible/vars.yaml
    ```
## Fichero main.tf
Fichero de configuración de terraform.

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
  - Creación de par de claves ssh.
  - Creación de una maquina virtual.
    - Dos nucleos y 4 GB de Ram.
    - S.O. CentOs 7.5

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
- resource_group_id.
