FROM ubuntu

# Create needed directories
RUN mkdir -p \
      /etc/environment.d \
      /var/gonano/db \
      /var/gonano/run \
      /data \
      /var/nanobox \
      /data/var/db \
      /var/nanobox

# Install curl and wget
RUN apt-get update -qq && \
    apt-get install -y curl wget vim sudo net-tools netcat iproute iputils-ping netbase && \
    apt-get clean all

# Install pkgsrc "gonano" bootstrap
RUN curl -s http://pkgsrc.nanobox.io/nanobox/gonano/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://pkgsrc.nanobox.io/nanobox/gonano/Linux/" > /opt/gonano/etc/pkgin/repositories.conf && \
    /opt/gonano/sbin/pkg_admin rebuild && \
    rm -rf /var/gonano/db/pkgin && \opt/gonano/bin/pkgin -y up && \
    /opt/gonano/bin/pkgin -y in hookit siphon && \
    rm -rf \
      /var/gonano/db/pkgin \
      /opt/gonano/share/doc \
      /opt/gonano/share/ri \
      /opt/gonano/share/examples \
      /opt/gonano/man

# symlink certs folder from /etc/ssl/certs to /opt/gonano/etc/openssl/certs
RUN rm -rf /opt/gonano/etc/openssl/certs/ && \
    ln -sf /etc/ssl/certs /opt/gonano/etc/openssl/certs

# add gonano binaries on path 
ENV PATH /opt/gonano/sbin:/opt/gonano/bin:$PATH

# Add gonano user
RUN groupadd gonano && \
    useradd -m -s '/bin/bash' -p `openssl passwd -1 gonano` -g gonano gonano && \
    passwd -u gonano

# install pkgsrc "base" bootstrap
RUN curl -s http://pkgsrc.nanobox.io/nanobox/base/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://pkgsrc.nanobox.io/nanobox/base/Linux/" > /data/etc/pkgin/repositories.conf && \
    /data/sbin/pkg_admin rebuild && \
    rm -rf /data/var/db/pkgin && \data/bin/pkgin -y up && \
    rm -rf \
      /data/var/db/pkgin \
      /data/share/doc \
      /data/share/ri \
      /data/share/examples \
      /data/opt/gonano/man \
      /data/var/db/pkgin/cache && \
    chown -R gonano:gonano /data

# symlink certs folder from /etc/ssl/certs to /data/etc/openssl/certs
RUN rm -rf /data/etc/openssl/certs/ && \
    ln -sf /etc/ssl/certs /data/etc/openssl/certs

# Copy files
ADD files/. /

# Own all gonano files
RUN chown -R gonano:gonano /home/gonano

# Generate and set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Cleanup disk
RUN docker_prepare
