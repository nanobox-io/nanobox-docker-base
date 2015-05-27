FROM ubuntu

# Install from apt-get until packages are ready
RUN apt-get -y update && apt-get -y install supervisor openssh-server curl vim && mkdir /var/run/sshd

# Add gonano user
RUN groupadd gonano
RUN useradd -m -s '/bin/bash' -p `openssl passwd -1 gonano` -g gonano gonano
RUN passwd -u gonano

# Create needed directories
RUN mkdir /home/gonano/.ssh && chown gonano. /home/gonano/.ssh
RUN mkdir -p /opt/local/etc/ssh
RUN mkdir -p /var/local/run
RUN mkdir -p /opt/local/sbin

# Copy files
ADD files/motd /etc/motd
ADD files/sudoers /etc/sudoers
ADD files/bashrc /home/gonano/.bashrc
ADD files/ssh_config /home/gonano/.ssh/config
ADD files/sshd_config /opt/local/etc/ssh/sshd_config
ADD files/ssh_kernel_auth /opt/local/sbin/ssh_kernel_auth
ADD files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add ssh keys
RUN ssh-keygen -f /opt/local/etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /opt/local/etc/ssh/ssh_host_dsa_key -N '' -t dsa
RUN ssh-keygen -f /opt/local/etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa

# Cleanup disk
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN dd if=/dev/zero of=temp bs=1M; rm -f temp && sync && sync 

# Allow ssh
EXPOSE 22

# Run supervisord automatically
CMD /usr/bin/supervisord
