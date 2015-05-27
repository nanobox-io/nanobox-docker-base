# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box     = "nanobox/boot2docker"
  config.vm.box_url = "https://bitbucket.org/beuford/boot2docker-nanobox/downloads/pb-b2d_virtualbox.box"

  config.vm.synced_folder ".", "/vagrant", readonly: false

  # Add docker credentials
  config.vm.provision "file", source: "~/.dockercfg", destination: "/home/docker/.dockercfg"

  # Build base image
  config.vm.provision "shell", inline: "docker build #{ENV['docker_user']}/base /vagrant"

  # Publish image to dockerhub
  config.vm.provision "shell", inline: "docker push #{ENV['docker_user']}/base"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
  end

end
