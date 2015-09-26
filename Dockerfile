FROM ubuntu

# Create folders for gonano pkgsrc bootstrap
RUN mkdir -p /var/gonano/db && \
    mkdir -p /var/gonano/run && \
    mkdir -p /data && \
    mkdir -p /var/nanobox && \
    mkdir -p /data/var/db

# Install curl and wget
RUN apt-get update -qq && \
    apt-get install -y curl wget vim && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Install pkgsrc "gonano" bootstrap
RUN curl -s http://pkgsrc.nanobox.io/nanobox/gonano/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://pkgsrc.nanobox.io/nanobox/gonano/Linux/" > /opt/gonano/etc/pkgin/repositories.conf && \
    /opt/gonano/sbin/pkg_admin rebuild && \
    rm -rf /var/gonano/db/pkgin && /opt/gonano/bin/pkgin -y up && \
    /opt/gonano/bin/pkgin -y in hookit && \
    rm -rf \
      /var/gonano/db/pkgin \
      /opt/gonano/share/doc \
      /opt/gonano/share/ri \
      /opt/gonano/share/examples \
      /opt/gonano/man

# add gonano binaries on path 
ENV PATH /opt/gonano/sbin:/opt/gonano/bin:$PATH

# Add gonano user
RUN groupadd gonano
RUN useradd -m -s '/bin/bash' -p `openssl passwd -1 gonano` -g gonano gonano
RUN passwd -u gonano

# install pkgsrc "base" bootstrap
RUN curl -s http://pkgsrc.nanobox.io/nanobox/base/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://pkgsrc.nanobox.io/nanobox/base/Linux/" > /data/etc/pkgin/repositories.conf && \
    /data/sbin/pkg_admin rebuild && \
    rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up && \
    rm -rf \
      /data/var/db/pkgin \
      /data/share/doc \
      /data/share/ri \
      /data/share/examples \
      /data/opt/gonano/man \
      /data/var/db/pkgin/cache && \
    chown -R gonano /data

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
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
