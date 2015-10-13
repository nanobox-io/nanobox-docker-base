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
RUN apt-get update -qq
RUN apt-get install -y curl wget vim
RUN apt-get clean all

# Install pkgsrc "gonano" bootstrap
RUN curl -s http://pkgsrc.nanobox.io/nanobox/gonano/Linux/bootstrap.tar.gz | tar -C / -zxf -
RUN echo "http://pkgsrc.nanobox.io/nanobox/gonano/Linux/" > /opt/gonano/etc/pkgin/repositories.conf
RUN /opt/gonano/sbin/pkg_admin rebuild
RUN rm -rf /var/gonano/db/pkgin && /opt/gonano/bin/pkgin -y up
RUN /opt/gonano/bin/pkgin -y in hookit
RUN rm -rf \
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
RUN curl -s http://pkgsrc.nanobox.io/nanobox/base/Linux/bootstrap.tar.gz | tar -C / -zxf -
RUN echo "http://pkgsrc.nanobox.io/nanobox/base/Linux/" > /data/etc/pkgin/repositories.conf
RUN /data/sbin/pkg_admin rebuild
RUN rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up
RUN rm -rf \
      /data/var/db/pkgin \
      /data/share/doc \
      /data/share/ri \
      /data/share/examples \
      /data/opt/gonano/man \
      /data/var/db/pkgin/cache
RUN chown -R gonano /data

# Copy files
ADD files/. /

# Cleanup disk
RUN docker_prepare
