FROM fedora:26
MAINTAINER Michal Karm Babacek <karm@redhat.com>

# One needs a free registration to get an evaluation zip of JBCS Apache HTTP Server
# from http://bit.ly/download-jbcs-httpd-now
ENV JBCS_ZIP         jbcs-httpd24-httpd-2.4.23-RHEL7-x86_64.zip
ENV JBCS_PATCH_ZIP   jbcs-httpd24-httpd-2.4.23-SP1-RHEL7-x86_64.zip
ENV JBCS_HOME        /opt/jbcs-httpd24-2.4
ENV MOD_CLUSTER_CONF ${JBCS_HOME}/httpd/conf.d/mod_cluster.conf
ENV SSL_CONF         ${JBCS_HOME}/httpd/conf.d/ssl.conf
ENV HTTPD_CONF       ${JBCS_HOME}/httpd/conf/httpd.conf

WORKDIR /opt

RUN dnf -y update && \
    dnf -y install unzip openssl which hostname apr apr-devel apr-util apr-util-devel apr-util-ldap elinks mailcap && \
    dnf -y clean all

#Download (or copy) and install JBCS, the resulting instasllation is in /opt/jbcs-httpd24-2.4

ADD ["${JBCS_ZIP}", "${JBCS_PATCH_ZIP}", "/opt/"]

RUN cd /opt && \
    unzip ${JBCS_ZIP} -d /opt/ && \
    yes | unzip ${JBCS_PATCH_ZIP} -d /opt/ && \
    rm -rf ${JBCS_ZIP} && rm -rf ${JBCS_PATCH_ZIP} && \
    cd ${JBCS_HOME}/httpd && \
    ./.postinstall && \
# We don't need Kerberos, unload
    rm -f ${JBCS_HOME}/httpd/conf.modules.d/10-auth_kerb.conf && \
# We don't need SystemD integration in the container
    rm -f ${JBCS_HOME}/httpd/conf.modules.d/00-systemd.conf

# Container specific configuration for runtime use
ADD mod_cluster.conf ${MOD_CLUSTER_CONF}
ADD runtimeconfig.sh ${JBCS_HOME}/httpd/sbin/
RUN sed -i "3i\${JBCS_HOME}/httpd/sbin/runtimeconfig.sh" ${JBCS_HOME}/httpd/sbin/apachectl

EXPOSE 80/tcp
EXPOSE 443/tcp
EXPOSE 6666/tcp
EXPOSE 23364/udp

VOLUME ["/opt/jbcs-httpd24-2.4/httpd/logs"]

CMD ["/opt/jbcs-httpd24-2.4/httpd/sbin/apachectl", "start", "-DFOREGROUND"]
