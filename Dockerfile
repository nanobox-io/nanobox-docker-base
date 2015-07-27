FROM ubuntu

# Create folders for gonano pkgsrc bootstrap
RUN mkdir -p /var/gonano/db && \
    mkdir -p /opt/gonano/etc/ssh && \
    mkdir -p /var/gonano/run && \
    mkdir -p /opt/gonano/sbin && \
    mkdir -p /opt/gonano/hookit/mod && \
    mkdir -p /opt/gonano/etc/pkgin && \
    mkdir -p /opt/gonano/etc/hookyd

# Install curl and wget
RUN apt-get update -qq && \
    apt-get install -y curl wget vim && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Install pkgin packages
RUN curl -s http://pkgsrc.nanobox.io/nanobox/gonano/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://pkgsrc.nanobox.io/nanobox/gonano/Linux/" > /opt/gonano/etc/pkgin/repositories.conf && \
    /opt/gonano/sbin/pkg_admin rebuild && \
    rm -rf /var/gonano/db/pkgin && /opt/gonano/bin/pkgin -y up && \
    /opt/gonano/bin/pkgin -y in hookit && \
    rm -rf \
      /var/lib/apt/lists/* \
      /tmp/* \
      /var/tmp/* \
      /var/gonano/db/pkgin \
      /opt/gonano/share/doc \
      /opt/gonano/share/ri \
      /opt/gonano/share/examples \
      /opt/gonano/man

ENV PATH /opt/gonano/sbin:/opt/gonano/bin:$PATH

# Add gonano user
RUN groupadd gonano
RUN useradd -m -s '/bin/bash' -p `openssl passwd -1 gonano` -g gonano gonano
RUN passwd -u gonano

# Create needed directories
RUN mkdir -p /etc/environment.d

# Copy files
ADD files/bin/* /sbin/
ADD files/motd /etc/motd
ADD files/sudoers /etc/sudoers
ADD files/rootrc /root/.bashrc
ADD files/bashrc /home/gonano/.bashrc
ADD files/environment /etc/environment
RUN chmod 644 /etc/environment

# Cleanup disk
RUN rm -rf /tmp/* /var/tmp/*
