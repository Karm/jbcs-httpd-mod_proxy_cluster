# Env props and their defaults

* ```HTTPD_NIC:-eth0```
* ```HTTPD_ADDR_PREFIX:-172```
* ```MOD_CLUSTER_LISTENER_PORT:-6666```
* ```MOD_CLUSTER_MANAGER_REQUIRE:-all granted```
* ```MOD_CLUSTER_MCMP_REQUIRE:-all granted```
* ```MOD_CLUSTER_UDP_MULTICAST_ADDRESS:-224.0.1.105```
* ```MOD_CLUSTER_UDP_MULTICAST_PORT:-23364```

* ```HTTPD_SERVER_NAME:-${MYIP}```
** You might also use ```${HOSTNAME}``` instead of ```${MYIP}```, e.g. in DockerCloud or in Rancher. 
* ```HTTPD_LISTEN_PORT:-80```
* ```HTTPD_LISTEN_ADDRESS:-${MYIP}```
* ```HTTPD_LOG_LEVEL:-warn```

* ```HTTPD_SSL_LISTEN_PORT:-443```
* ```HTTPD_SSL_VHOST_NAME:-_default_```

# How to build the image

    sudo docker build -t karm/jbcs-mod_cluster:jbcs-2.4.6 .

# How to start the container
Note mapping to host's ip address, definitions of Docker Deamon provided Docker interface and expected conteiner ip address prefix.

    sudo docker run -p 192.168.122.156:80:80/tcp \
                    -p 192.168.122.156:443:443/tcp \
                    -p 192.168.122.156:6666:6666/tcp \
                    -p 192.168.122.156:23364:23364/udp \
                    -e 'HTTPD_NIC=eth0' \
                    -e 'HTTPD_ADDR_PREFIX=172' \
                    -e 'MOD_CLUSTER_LISTENER_PORT=6666' \
                    -e 'MOD_CLUSTER_MANAGER_REQUIRE=all granted' \
                    -e 'MOD_CLUSTER_MCMP_REQUIRE=all granted' \
                    -e 'MOD_CLUSTER_UDP_MULTICAST_ADDRESS=224.0.1.105' \
                    -e 'MOD_CLUSTER_UDP_MULTICAST_PORT=23364' \
                    -e 'HTTPD_LISTEN_PORT=80' \
                    -e 'HTTPD_LOG_LEVEL=debug' \
                    -e 'HTTPD_SSL_LISTEN_PORT=443' \
                    -e 'HTTPD_SSL_VHOST_NAME=_default_' \
                    -d -i --name jbcs-httpd-mod_cluster karm/jbcs-mod_cluster:jbcs-2.4.6
