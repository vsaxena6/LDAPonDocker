######################################################################################
# This dockerfile will describe how to deploy the Single Sign On (SSO) for Integral. #
# The default integral SSO involves both OpenLDAP and CAS.                           #
######################################################################################

FROM centos:latest
######################################################################################
#Add User Group and Accounts.
######################################################################################
USER root
ARG LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib
RUN mkdir -p /u01/app
RUN groupadd integral
RUN cd /u01/app/ && mkdir integral
RUN chgrp -R integral /u01/app/integral/
RUN chmod -R 2775 /u01/app/integral/
RUN useradd -b /u01/app/integral/ -g integral Vishal-test-user
RUN mkdir –p /u01/app/integral/cas
RUN cd  /u01/app/integral/ && mkdir life/
RUN cd  /u01/app/integral/ && mkdir  polisy/
RUN cd /u01/app/integral/ && mkdir group/
RUN cd /u01/app/integral/ && mkdir hub/
RUN cd /u01/app/integral/ && mkdir ipos/
######################################################################################
# ADD USER #
######################################################################################
RUN useradd -b /u01/app/integral/cas/ -g integral cas
RUN useradd -b /u01/app/integral/life/ -g integral life
RUN useradd -b /u01/app/integral/polisy/ -g integral polisy
RUN useradd -b /u01/app/integral/group/ -g integral group
RUN useradd -b /u01/app/integral/hub/ -g integral hub
RUN useradd -b /u01/app/integral/ipos/ -g integral ipos
######################################################################################
RUN yum update -y
RUN yum install -y wget perl make gcc
RUN wget http://mirror.centos.org/centos/7/extras/x86_64/Packages/epel-release-7-11.noarch.rpm
RUN rpm -Uvh epel-release*rpm
RUN yum install gcc-c++-x86_64-linux-gnu -y
RUN yum install cyrus-sasl-devel -y
RUN yum install cyrus-sasl openssl-devel -y
RUN wget http://www.openssl.org/source/openssl-1.0.1h.tar.gz
RUN tar -zxvf openssl-1.0.1h.tar.gz
RUN cd openssl-1.0.1h && ./config shared --openssldir=/usr/local &&  make && make install
RUN openssl version
RUN wget http://download.oracle.com/berkeley-db/db-6.1.19.tar.gz --no-check-certificate
RUN tar -zxvf db-6.1.19.tar.gz
RUN cd db-6.1.19 && cd build_unix && ../dist/configure --prefix=/usr/local/ && make && make install
RUN echo -e "include ld.so.conf.d/*.conf\n/usr/local/lib/\n/usr/local/lib64/\n/usr/lib\n/usr/lib64" >> /etc/ld.so.conf 
RUN wget https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.4.39.tgz
RUN tar -zxvf openldap-2.4.39.tgz
RUN  cd openldap-2.4.39/ && ./configure --enable-spasswd=yes --enable-syncprov=yes --enable-ppolicy=yes --enable-overlays=yes --enable-sssvlv -enable-shared=yes --with-cyrus-sasl=yes --prefix=/etc/openldap/ 
RUN  cd openldap-2.4.39/ && make depend && make && make test && make install
RUN yum install which lsof openldap-clients -y
COPY slapd.conf /etc/openldap/etc/openldap/
RUN /etc/openldap/libexec/slapd
COPY integral.ldif  /etc/openldap/var/openldap-data/
EXPOSE 389
