# Caso práctico número 2 - Curso DevOps

## Descripción de la actividad

 El caso práctico 2 consiste en desplegar los siguientes elementos:

- Un (1) repositorio de imágenes de contenedores sobre infraestructura de Microsoft Azure mediante el servicio Azure Container Registry (ACR).
- Una (1) aplicación en forma de contenedor utilizando Podman sobre una máquina virtual en Azure.
- Un (1) cluster de Kubernetes como servicio gestionado en Microsoft Azure (AKS).
- Una (1) aplicación con almacenamiento persistente sobre el cluster AKS.

## Solución propuesta.

Con **terraform** se creará la siguiente infraestructura en Azure:
- Resource Group.
- Container Registry.
- Virtual Network.
- Subnet.
- Ip Public.  
- Security Group.
  - Security rule port 22.
  - Security rule port 80.
- Una maquina virtual.
    - 2 cpu virtuales y 4 GiB de Ram.
    - Sistema Operativo: CentOS 8
- Azure Container Registry (ACR). Como repositorio de las imagenes que se usarán en la solución.
- Azure Kubernetes Service (AKS).

Con **Ansible** se harán las siguientes acciones:
- Subir al **ACR** de tres imagenes:
  - Imagen de servidor web **nginx**.
  - Imagen de servidor de base de datos **MySql**.
  - Imagen de la web **phpmyadmin**. 
- En la maquina virtual se instalará **podman** y se levantará un contenedor de una imagen de **nginx** modificada con estas características:
  - Acceso por https (puerto 443).
  - Autentificación de acceso a la página de usuario y contraseña.
  - Página web con el enlace del repositorio del caso practico 2.
  - El contenedor se iniciará al arrancar la maquina virtual (servicio).
- En el **AKS** se creará un volumen persistente y se instalaran dos contenedores:
  - Contenedor de MySql. La base de datos estará alojada en el volumen persistente. No se tendrá acceso desde el exterior.
  - Contenedor de phpmyadmin. Se tendrá acceso desde el exterior por http (puerto 80) y se podrá conectar al contener de MySql (introduciendo en la página de inicio la ip 127.0.0.1 o localhost) o a cualquier otra base de datos que este públicada. 

## Secciones del código de la solución propuesta.

[Terraform](/terraform)

[Ansible](/ansible)
