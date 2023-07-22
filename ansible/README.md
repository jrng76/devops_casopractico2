# Ansible
Al ejecutar el script de la parte de **terraform**, generará de manera automática los ficheros de inventary, id_rsa_vm (clave privada para la conexión por ssh) y vars.yaml. De modo que ya tendremos la ip de la vm, la clave privada para acceder a la vm y las credenciales del acr.

## Descripción  de los ficheros:

### Script deploy.sh
El script ejecuta en este orden lo siguiente:
- El playbook llamado **playbook.yaml**
```bash
ansible-playbook -i inventary playbook.yaml
```
- **az aks get-credentials** para obtener las credenciales de acceso al AKS.
```bash
az aks get-credentials --resource-group rg-casopractico2TF --name aks-aksjrng76
```
- El playbook llamado **playbookaks.yaml**
```bash
ansible-playbook playbookaks.yaml
```

### playbook.yaml
Fichero playbook que contiene las instrucciones para conectarse a la maquina virtual creada anteriormente y realiza las siguientes acciones:
- Instalar **podman**.
- Instalar **httpd-tools**.
- Instalar **passlib** python package (necesario para community.general.htpasswd).
- Crea ek directorio **nginx**.
- Copia el fichero **Containerfile** en el directorio nginx (se usará más adelante para construir la imagen del servidor nginx).
- Copia el fichero **index.html** en el directorio nginx.
- Copia el fichero **default.conf**
- Crea el fichero **.htpassword** en el directorio nginx con:
  - usuario: **admin**
  - password: **mypassword**
- Genera la clave privada con **OpenSSL private key** con los valores por defecto (4096 bits, RSA) con el nombre de **privkey.pem** en el directorio nginx.
- Genero el **Certificate Signing Request (csr)** para nginx con el nombre **jrng76.com.csr** en el directorio nginx.
- Genera el **certificado autofirmado (.crt)** para con el nombre **cert.crt** en el directorio nginx.
- Crea el directorio **phpmyadmin**
- Copia el fichero **Containerfile** en el directorio **phpmyadmin** (se utilizará para construir la imagen de phpmyadmin)
- Pull de la imagen de MySQL.
- Cambia el tag a la imagen de MySQl por **jrng76mysql:casopractico2**.
- Crea el registro de login por defecto en /etc/containers/auth.json
- Construye la imagen de nginx y la sube al **ACR** de Azure usando el registro de login auth.json
- Sube la imagen de mysql al **ACR** de Azure usando el registro de login auth.json
- Construye la imagen de phpmyadmin y la subo al **ACR** de Azure usando el registro de login auth.json
- Borra la imagen **nginx** que ya no es necesaria
- Borra la imagen **jrng76nginx** local que ya no es necesaria
- Borra la imagen **mysql** que ya no es necesaria.
- Borra la imagen **jrng76mysql** local que ya no es necesaria.
- Borra la imagen **phpmyadmin** que ya no es necesaria.
- Borra la imagen **jrng76phpmyadmin** local que ya no es necesaria.
- Se logea con el acr de Azure y crea el contenedor llamado **containernginx** de la imagen jrng76.azurecr.io/nginx/jrng76nginx:casopractico2 (servidor de nginx) y redirije el puerto local 443 al puerto 443 del contenedor.
- Genera el fichero unidad systemd para el contenedor **containernginx**.
- Activa e inicia el servicio **container-containernginx.service** para que al reiniciar la vm el contenedor se inicie también.

### vars.yaml
Fichero de variables del **ACR** (usuario, contraseña, nombre del servidor acr y rutas de las imagenes almacenadas) generado por el script execterraform.sh de la parte de terraform. 

### playbookaks.yaml
En este playbook:
- Se definen los objetos deployment y servicios obtenidos del fichero **dual.j2**.
- Se crea el namespace de trabajo.
- Se crean el Deployments y servicios de la aplicación.
  
### varsaks.yaml
Fichero de yaml con las variables necesarias (nombre imagen, limites de cpu, memoria, etc.) para el despliegue de los contenedores **phpmyadmin** y **MySql**, el nombre del **namespace** (jrng76namespace) que se crea y el directorio de trabajo.

### templates/dual.j2
Template donde se define el deployment para que dos contenedores en el mismo pod. Uno con phpmyadmin y el otro con un servidor de MySql 8. El contenedor de MySql se configura con los siguientes valores:
- Contraseña del usuario root: **toor**
- Otro usuario: **usermysql**
- Contraseña del usuario usermysql: **mypassword**
- Puerto: **3306**

Se define el servicio **loadbalancer** para el contenedor de phpmyadmin en el puerto 80.
Se define el **PersistentVolumeClaim** para crear el volumen persistente que utilizará el servidor de MySQL para almacenar las bases de datos.

### phpmyadmin/Containerfile
Fichero para la construcción de la imagen de **phpmyadmin**. La imagen resultante permitirá introducir en la página de login de phpmyadmin el nombre o ip del servidor de MySql.

### nginx/Containerfile
Fichero para la construcción de la imagen de **nginx** personalizada con una paǵina web por defecto, acceso a la página por https y validación básica por usuario y contraseña.

### nginx/default.conf
Fichero de configuración del servidor web **ngnix** para que se acceda por defecto por https y sea necesario autentificación.

### nginx/index.html
Fichero con la página web que tendrá alojada en el servidor web **nginx**. 