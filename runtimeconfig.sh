#!/bin/bash

# @author Michal Karm Babacek

# Network interface and IP address

echo "STAT: `networkctl status`" >> /var/log/ip.log
echo "STAT ${HTTPD_NIC:-eth0}: `networkctl status ${HTTPD_NIC:-eth0}`" >> /var/log/ip.log

# Wait for the interface to wake up
TIMEOUT=20
MYIP=""
while [[ "${MYIP}X" == "X" ]] && [[ "${TIMEOUT}" -gt 0 ]]; do
    echo "Loop ${TIMEOUT}" >> /var/log/ip.log
    MYIP="`networkctl status ${HTTPD_NIC:-eth0} | awk '{if($1~/Address:/){printf($2);}}'`"
    export MYIP
    let TIMEOUT=$TIMEOUT-1
    if [[ "${MYIP}" == ${HTTPD_ADDR_PREFIX:-172}* ]]; then
        break;
    else 
        MYIP=""
        sleep 1;
    fi
done
echo -e "MYIP: ${MYIP}\nMYNIC: ${HTTPD_NIC:-eth0}" >> /var/log/ip.log
if [[ "${MYIP}X" == "X" ]]; then 
    echo "${HTTPD_NIC:-eth0} Interface error. " >> /var/log/ip.log
    exit 1
fi

# Runtime configuration

# mod_cluster
sed -i "s/@MOD_CLUSTER_LISTENER_ADDRESS@/${MYIP}/g"                                    ${MOD_CLUSTER_CONF}
sed -i "s/@MOD_CLUSTER_LISTENER_PORT@/${MOD_CLUSTER_LISTENER_PORT:-6666}/g"            ${MOD_CLUSTER_CONF}
sed -i "s/@MOD_CLUSTER_MANAGER_REQUIRE@/${MOD_CLUSTER_MANAGER_REQUIRE:-all granted}/g" ${MOD_CLUSTER_CONF}
sed -i "s/@MOD_CLUSTER_MCMP_REQUIRE@/${MOD_CLUSTER_MCMP_REQUIRE:-all granted}/g"       ${MOD_CLUSTER_CONF}
sed -i "s/@MOD_CLUSTER_UDP_MULTICAST_ADDRESS@/${MOD_CLUSTER_UDP_MULTICAST_ADDRESS:-224.0.1.105}/g" ${MOD_CLUSTER_CONF}
sed -i "s/@MOD_CLUSTER_UDP_MULTICAST_PORT@/${MOD_CLUSTER_UDP_MULTICAST_PORT:-23364}/g" ${MOD_CLUSTER_CONF}
sed -i "s/@MOD_CLUSTER_MANAGER_DIR@/${JWS_HOME}\/httpd\/cache\/mod_cluster/g"          ${MOD_CLUSTER_CONF}

# httpd
sed -i "s/^ServerName.*/ServerName ${HTTPD_SERVER_NAME:-${MYIP}}:${HTTPD_LISTEN_PORT:-80}/g" ${HTTPD_CONF}
sed -i "s/^Listen.*/Listen ${HTTPD_LISTEN_ADDRESS:-${MYIP}}:${HTTPD_LISTEN_PORT:-80}/g"          ${HTTPD_CONF}
sed -i "s/^LogLevel.*/LogLevel ${HTTPD_LOG_LEVEL:-warn}/g"                                       ${HTTPD_CONF}

sed -i "s/^Listen.*/Listen ${HTTPD_LISTEN_ADDRESS:-${MYIP}}:${HTTPD_SSL_LISTEN_PORT:-443}/g"     ${SSL_CONF}
sed -i "s/^LogLevel.*/LogLevel ${HTTPD_LOG_LEVEL:-warn}/g"                                       ${SSL_CONF}
sed -i "s/^<VirtualHost.*/<VirtualHost ${HTTPD_SSL_VHOST_NAME:-_default_}:${HTTPD_SSL_LISTEN_PORT:-443}>/g" ${SSL_CONF}

echo Done. >> /var/log/ip.log
