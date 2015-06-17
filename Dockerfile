FROM ubuntu

# Install from apt-get until packages are ready
RUN apt-get -y update && apt-get -y install runit openssh-server curl vim

# Add gonano user
RUN groupadd gonano
RUN useradd -m -s '/bin/bash' -p `openssl passwd -1 gonano` -g gonano gonano
RUN passwd -u gonano

# Create needed directories
RUN mkdir /home/gonano/.ssh && chown gonano. /home/gonano/.ssh
RUN mkdir -p /var/run/sshd
RUN mkdir -p /opt/gonano/etc/ssh
RUN mkdir -p /var/gonano/run
RUN mkdir -p /opt/gonano/sbin
RUN mkdir -p /opt/gonano/hookit/mod
RUN mkdir -p /var/log/hooky
RUN mkdir -p /var/gonano/db
RUN mkdir -p /opt/gonano/etc/pkgin
RUN mkdir -p /etc/environment.d
RUN mkdir -p /opt/gonano/etc/hookyd

# Copy files
ADD files/motd /etc/motd
ADD files/sudoers /etc/sudoers
ADD files/rootrc /root/.bashrc
ADD files/bashrc /home/gonano/.bashrc
ADD files/environment /etc/environment
RUN chmod 644 /etc/environment
ADD files/ssh_config /home/gonano/.ssh/config
ADD files/sshd_config /opt/gonano/etc/ssh/sshd_config
ADD files/ssh_kernel_auth /opt/gonano/sbin/ssh_kernel_auth
ADD files/bin/* /sbin/
ADD files/service/. /etc/service/
ADD scripts/. /var/tmp/

# Install init
RUN /var/tmp/install-init

# Install pkgin packages
RUN curl -k http://pkgsrc.nanobox.io/nanobox/gonano/Linux/bootstrap.tar.gz | gunzip -c | tar -C / -xf -
RUN echo "http://pkgsrc.nanobox.io/nanobox/gonano/Linux/" > /opt/gonano/etc/pkgin/repositories.conf
RUN /opt/gonano/sbin/pkg_admin rebuild
RUN rm -rf /var/gonano/db/pkgin && /opt/gonano/bin/pkgin -y up
RUN /opt/gonano/bin/pkgin -y in hookit hookyd
#RUN /opt/gonano/bin/pkgin -y in narc openssh-server curl vim runit

#TEMP - TEST WITHOUT
# RUN curl -ksL https://github.com/pagodabox/hookyd/archive/v0.0.6.tar.gz | tar -C /opt/gonano/hookyd --strip-components=1 -zxf -
# RUN echo "{\"port\":5540,\"ip\":\"0.0.0.0\",\"hooky\":\"hookit\",\"hook_dir\":\"/opt/gonano/hookit/mod/hooks\"}" > /opt/gonano/etc/hookyd/hookyd.conf
# RUN echo "{\"port\":5540,\"ip\":\"0.0.0.0\",\"hooky\":\"hookit\",\"hook_dir\":\"/opt/gonano/hookit/mod/hooks\"}" > /opt/local/etc/hookyd/hookyd.conf
# RUN ln -sf /opt/gonano/bin/ruby200 /opt/gonano/bin/ruby

# Add ssh keys
RUN ssh-keygen -f /opt/gonano/etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /opt/gonano/etc/ssh/ssh_host_dsa_key -N '' -t dsa
RUN ssh-keygen -f /opt/gonano/etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa

# Cleanup disk
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/gonano/db/pkgin
# RUN dd if=/dev/zero of=temp bs=1M; rm -f temp && sync && sync

# Allow ssh
EXPOSE 22

# Run runit automatically
CMD /sbin/my_init
