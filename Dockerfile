FROM ubuntu:latest

ENV MAIL_IN_A_BOX_CONTAINER=1

ENV PRIMARY_HOSTNAME "box.example.com"
ENV PUBLIC_IP "93.184.216.34"
ENV PUBLIC_IPV6 "2001:db8:3333:4444:5555:6666:7777:8888"
ENV PRIVATE_IP "127.0.0.1"
ENV PRIVATE_IPV6 "::1/128"

ENV MAIL_IN_A_BOX_USER "mailinabox"
ENV MAIL_IN_A_BOX_PW "admin"

ENV EMAIL_ADDR "admin@example.com"

ENV STORAGE_USER=${MAIL_IN_A_BOX_USER}
ENV STORAGE_ROOT=/home/${STORAGE_USER}

ENV NONINTERACTIVE=1

#managed by container runtime, TODO: must be done !
ENV DISABLE_FIREWALL=1


RUN groupadd ${MAIL_IN_A_BOX_USER}
RUN useradd -rm -d /home/${MAIL_IN_A_BOX_USER} -s /bin/bash -g root -G sudo -u 1001 ${MAIL_IN_A_BOX_USER} -p "$(openssl passwd -1 ${MAIL_IN_A_BOX_PW})"
RUN usermod -aG ${MAIL_IN_A_BOX_USER} ${MAIL_IN_A_BOX_USER}
RUN usermod -aG sudo ${MAIL_IN_A_BOX_USER}


# update and upgrade
RUN apt-get update && \
    apt-get upgrade -y

# install the requirements
RUN apt-get install -y sudo
RUN apt-get install -y wget sudo curl systemd lsb-core fail2ban nano python-pip netcat-openbsd sed bind9-host locales ufw
RUN apt-get install -y git
RUN     locale-gen en_US.UTF-8
RUN     apt-get purge vim* -y
RUN apt-get install python3 python3-pip -y
RUN apt install sqlite3
RUN     pip install utils
#RUN     pip install sqlite3
RUN     pip3 install "email_validator==0.1.0-rc4"

RUN echo '${MAIL_IN_A_BOX_USER} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


# start the installer
#run as sudo user
#ADD https://mailinabox.email/setup.sh /home/${MAIL_IN_A_BOX_USER}/
ADD setup.sh /home/${MAIL_IN_A_BOX_USER}/
RUN chown ${MAIL_IN_A_BOX_USER} /home/${MAIL_IN_A_BOX_USER}/setup.sh
RUN chmod u+x /home/${MAIL_IN_A_BOX_USER}/setup.sh

USER  ${MAIL_IN_A_BOX_USER}
RUN ["sh", "-c", "sudo -E /home/${MAIL_IN_A_BOX_USER}/setup.sh"]

