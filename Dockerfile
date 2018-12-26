FROM ubuntu:trusty

RUN apt-get update && \
    apt-get -y -f install \
    openssh-server autossh pwgen sshpass && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /var/run/sshd && \
    mkdir -p /root/.ssh && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    echo "GatewayPorts yes" >> /etc/ssh/sshd_config && \
    rm -rf /var/lib/apt/lists/*

ADD bin/run.sh /run.sh
RUN chmod +x /*.sh

ENV PUBLIC_HOST_ADDR **None**
ENV PUBLIC_HOST_PORT **None**
ENV PROXY_PORT **None**
ENV DESTINATION_PORT **None**

CMD ["/run.sh"]
