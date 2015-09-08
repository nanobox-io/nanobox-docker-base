# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box     = "dduportal/boot2docker"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "1024", "--ioapic", "on"]
  end

  config.vm.synced_folder ".", "/vagrant"
  config.vm.synced_folder "~/.docker", "/home/docker/.docker"

  # wait for docker to be running
  config.vm.provision "shell", inline: <<-SCRIPT
  echo "Waiting for docker sock file"
  while [ ! -S /var/run/docker.sock ]; do
    sleep 1
  done
  SCRIPT
end
