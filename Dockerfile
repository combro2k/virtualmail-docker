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
RUN groupadd vmail && useradd vmail -g vmail -s /sbin/nologin -d /var/vmail && chmod 0777 /var/vmail

RUN if [ !-e /root/mysqlpass ]; then pwgen -1 24 -B > /root/mysqlpass && mysqladmin password `cat /root/mysqlpass` ; fi

VOLUME ["/etc/postfix", "/var/vmail", "/etc/dovecot"]

ADD configs/dovecot /etc/dovecot
ADD configs/postfix /etc/postfix
ADD configs/dovecot-mysql.conf /etc/dovecot-mysql.conf

#RUN sed -i.bak 's/myhostname = mail.e-combined.nl/myhostname = test/g' /etc/postfix/main.cf

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22
