#!/bin/bash
echo "--> Generando plan de terraform. <--"
terraform plan -out "MyPlan"
status=$?
if [ $status -eq 0 ]; then
    echo "--> Aplicando plan <--"
    terraform apply "MyPlan"
    echo "--> Generando fichero con la clave privada id_rsa_vm<--"
    terraform output -raw tls_private_key > ../ansible/id_rsa_vm
    echo "--> Cambiando permisos del fichero id_rsa_vm con la clave privada <--"
    chmod 600 ../ansible/id_rsa_vm
    echo "--> Mostrando las variables output del plan <--"
    terraform refresh
    echo "--> Creando fichero inventary para ansible<--"
    echo "[hosts]" > ../ansible/inventary
    terraform output public_ip_address >> ../ansible/inventary
    echo "--> Creando fichero vars.yaml para ansible<--"
    echo "acr_user: $(terraform output acr_admin_user)" > ../ansible/vars.yaml
    echo "acr_pass: $(terraform output acr_admin_pass)" >> ../ansible/vars.yaml
    echo "acr_server: $(terraform output acr_login_server)" >> ../ansible/vars.yaml
    echo "acr_server_nginx: $(terraform output acr_login_server)/nginx" | sed -r 's/["]//g' >> ../ansible/vars.yaml
    echo "acr_server_mysql: $(terraform output acr_login_server)/mysql" | sed -r 's/["]//g' >> ../ansible/vars.yaml
    echo "acr_server_phpmyadmin: $(terraform output acr_login_server)/phpmyadmin" | sed -r 's/["]//g' >> ../ansible/vars.yaml
fi