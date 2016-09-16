# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box     = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "2048", "--ioapic", "on"]
  end

  config.vm.synced_folder ".", "/vagrant"

  # install docker
  config.vm.provision "shell", inline: <<-SCRIPT
    if [[ ! `which docker > /dev/null 2>&1` ]]; then
      # add docker's gpg key
      apt-key adv \
        --keyserver hkp://p80.pool.sks-keyservers.net:80 \
        --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
      # add the source to our apt sources
      echo \
        "deb https://apt.dockerproject.org/repo ubuntu-trusty main" \
          > /etc/apt/sources.list.d/docker.list
      # update the package index
      apt-get -y update
      # ensure the old repo is purged
      apt-get -y purge lxc-docker
      # install docker
      apt-get -y install docker-engine
      # clean up packages that aren't needed
      apt-get -y autoremove
      # add the vagrant user to the docker group
      usermod -aG docker vagrant
    fi
  SCRIPT

  # start docker
  config.vm.provision "shell", inline: <<-SCRIPT
    if [[ ! `service docker status | grep "start/running"` ]]; then
      # start the docker daemon
      service docker start
    fi
  SCRIPT

  # wait for docker to be running
  config.vm.provision "shell", inline: <<-SCRIPT
    echo "Waiting for docker sock file"
    while [ ! -S /var/run/docker.sock ]; do
      sleep 1
    done
  SCRIPT

  # create an adhoc network
  config.vm.provision "shell", inline: <<-SCRIPT
    if [[ ! `docker network ls | grep nanobox` ]]; then
      docker network create \
        --driver=bridge \
        --subnet=192.168.0.0/16 \
        --opt="com.docker.network.driver.mtu=1450" \
        --opt="com.docker.network.bridge.name=redd0" nanobox
    fi
  SCRIPT

  # build the docker image
  config.vm.provision "shell", inline: <<-SCRIPT
    echo "Building docker image..."
    cd /vagrant
    docker build -t nanobox/base --no-cache=true .
  SCRIPT

end
