FROM ubuntu:bionic

RUN apt-get update && \
    apt-get -y -f install \
    openssh-server autossh pwgen sshpass rsyslog && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /var/run/sshd && \
    mkdir -p /root/.ssh && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    sed -i "s/LogLevel.*/LogLevel VERBOSE/g" /etc/ssh/sshd_config && \
    sed -i "s/SyslogFacility.*/SyslogFacility AUTH/g" /etc/ssh/sshd_config && \    
    echo "GatewayPorts yes" >> /etc/ssh/sshd_config && \
    rm -rf /var/lib/apt/lists/*

ADD bin/run.sh /run.sh
RUN chmod +x /*.sh

CMD ["/run.sh"]
