# Ansible
Al ejecutar el script de la parte de **terraform**, generará de manera automática los ficheros de inventary, id_rsa_vm (clave privada para la conexión por ssh) y vars.yaml. De modo que ya tendremos la ip de la vm, la clave privada para acceder a la vm y las credenciales del acr.

## Script deploy.sh
El script ejecuta en este orden lo siguiente:
- El playbook llamado playbook.yaml
```
ansible-playbook -i inventary **playbook.yaml**
```
- **az aks get-credentials** para obtener las credenciales de acceso al AKS.
```
az aks get-credentials --resource-group rg-casopractico2TF --name aks-aksjrng76
```
- El playbook llamado **playbookaks.yaml**
```
ansible-playbook playbookaks.yaml
```

## playbook.yaml
Fichero playbook que contiene las instrucciones para conectarse a la maquina virtual creada anteriormente y realiza las siguientes acciones:
- Instalar podman.
- Instalar httpd-tools.
- Instalar passlib python package (necesario para community.general.htpasswd).
- Crea ek directorio nginx.
- Copia el fichero Containerfile en el directorio nginx (se usará más adelante para construir la imagen del servidor nginx).
- Copia el fichero index.html en el directorio nginx.
- Copia el fichero default.conf

## vars.yaml
Fichero de variables del acr (usuario, contraseña, nombre del servidor acr y rutas de las imagenes almacenadas) generado por el script execterraform.sh de la parte de terraform. 

## playbookaks.yaml
En este playbook:
- Se definen los objetos deployment y servicios obtenidos del fichero **dual.j2**.
- Se crea el namespace de trabajo.
- Se crean el Deployments y servicios de la aplicación.
  
## varsaks.yaml
Fichero de yaml con las variables necesarias (nombre imagen, limites de cpu, memoria, etc.) para el despliegue de los contenedores phpmyadmin y MySql, el nombre del namespace que se crea y el directorio de trabajo.

## Template dual.j2
Se define el deployment para que dos contenedores en el mismo pod. Uno con phpmyadmin y el otro con un servidor de MySql 8. 
Se define el servicio loadbalancer para el contenedor de phpmyadmin en el puerto 80.
Se define el PersistentVolumeClaim para crear el volumen persistente que utilizará el servidor de MySQL para almacenar las bases de datos.
