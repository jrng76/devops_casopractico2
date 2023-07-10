# Despliegue de la infraestructura con Terraform

## Extracción de la clave privada.
Una vez aplicado el plan de terraform se deberá utilizar el siguiente comando para extraer la clave privada que ha generado.

```
terraform output -raw tls_private_key > id_rsa_vm
```

Además será necesario cambiar los permisos de acceso al fichero de clave privada para que permita luego usarlo para la conexión ssh.

```
chmod 600 id_rsa_vm
```

## Extracción del usuario y contraseña del Azure Container Registry

```
terraform output -raw acr_admin_user
```

```
terraform output -raw acr_admin_pass
```

