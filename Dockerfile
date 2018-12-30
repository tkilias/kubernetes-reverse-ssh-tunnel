FROM ubuntu:bionic

RUN apt-get update && \
    apt-get -y -f install \
    openssh-server autossh pwgen sshpass rsyslog vim htop curl gnupg apt-transport-https && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y -f kubectl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /var/run/sshd && \
    mkdir -p /root/.ssh && \
    sed -i "s/#?UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/#?PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#?PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    sed -i "s/#?PermitEmptyPasswords.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    sed -i "s/#?GatewayPorts.*/GatewayPorts yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#?PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#?LogLevel.*/LogLevel VERBOSE/g" /etc/ssh/sshd_config && \
    sed -i "s/#?SyslogFacility.*/SyslogFacility AUTH/g" /etc/ssh/sshd_config && \
    sed -i "s/#?AllowTcpForwarding.*/AllowTcpForwarding yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#*AllowAgentForwarding.*/AllowAgentForwarding yes/g" /etc/ssh/sshd_config && \
    rm -rf /var/lib/apt/lists/*

ADD bin/run.sh /root/run.sh
ADD bin/ssh_agent.sh /root/ssh_agent.sh
ADD bin/ssh_config /root/.ssh/config

RUN chmod +x /root/*.sh && \
    echo "bash /root/ssh_agent.sh" >> .profile

CMD ["/root/run.sh"]
