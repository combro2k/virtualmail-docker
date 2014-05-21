# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:latest

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...
RUN apt-get update
RUN apt-get install -y dovecot-mysql dovecot-imapd postfix-mysql mysql-client procmail fetchmail amavisd-milter spamassassin postfix-gld mysql-server pwgen
RUN apt-get install -y apache2 apache2-bin apache2-data dbconfig-common libapache2-mod-php5 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libc-client2007e libxml2 lsof mlock php5-cli php5-common php5-imap php5-json php5-mysql php5-readline sgml-base wwwconfig-common xml-core

RUN curl http://sourceforge.net/projects/postfixadmin/files/postfixadmin/postfixadmin-2.91/postfixadmin_2.91-1_all.deb/download -L > /root/postfixadmin.deb
RUN dpkg -i /root/postfixadmin.deb

RUN mkdir -p /var/vmail /data
RUN groupadd vmail && useradd vmail -g vmail -s /sbin/nologin -d /var/vmail && chmod 0777 /var/vmail

VOLUME ["/etc/postfix", "/var/vmail", "/etc/dovecot", "/data"]

ADD configs/dovecot /etc/dovecot
ADD configs/postfix /etc/postfix

# Add init scripts
ADD my_init.d /etc/my_init.d
RUN chmod +x /etc/my_init.d/*

#RUN sed -i.bak 's/myhostname = mail.e-combined.nl/myhostname = test/g' /etc/postfix/main.cf

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22
