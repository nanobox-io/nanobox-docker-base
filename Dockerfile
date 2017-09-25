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
    apt-get install -y curl wget vim sudo net-tools netcat iproute iputils-ping netbase locales tzdata && \
    apt-get clean all

# Install pkgsrc "gonano" bootstrap
RUN curl -s http://d7zr21m3kwv6q.cloudfront.net/nanobox/gonano/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://d7zr21m3kwv6q.cloudfront.net/nanobox/gonano/Linux" > /opt/gonano/etc/pkgin/repositories.conf && \
    /opt/gonano/sbin/pkg_admin rebuild && \
    rm -rf /var/gonano/db/pkgin && \
    /opt/gonano/bin/pkgin -y up && \
    /opt/gonano/bin/pkgin -y in hookit siphon && \
    rm -rf \
      /var/gonano/db/pkgin \
      /opt/gonano/share/doc \
      /opt/gonano/share/ri \
      /opt/gonano/share/examples \
      /opt/gonano/man

# add gonano binaries on path 
ENV PATH /opt/gonano/sbin:/opt/gonano/bin:$PATH

# install pkgsrc "base" bootstrap
RUN curl -s http://d7zr21m3kwv6q.cloudfront.net/nanobox/base/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://d7zr21m3kwv6q.cloudfront.net/nanobox/base/Linux" > /data/etc/pkgin/repositories.conf && \
    /data/sbin/pkg_admin rebuild && \
    rm -rf /data/var/db/pkgin && \
    /data/bin/pkgin -y up && \
    rm -rf \
      /data/var/db/pkgin \
      /data/share/doc \
      /data/share/ri \
      /data/share/examples \
      /data/man \
      /data/var/db/pkgin/cache

# Add gonano user
RUN mkdir -p /data/var/home && \
    groupadd gonano && \
    useradd -m -s '/bin/bash' -p `openssl passwd -1 gonano` -g gonano gonano -d /data/var/home/gonano && \
    passwd -u gonano

# Copy files
ADD files/. /

# Own all gonano files
RUN chown -R gonano:gonano /data

# Set Permissions on the /root folder and /root/.ssh folder
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root && \
    chmod 0700 /root/.ssh

# Generate and set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set terminal
ENV TERM xterm

# Cleanup disk
RUN docker_prepare
