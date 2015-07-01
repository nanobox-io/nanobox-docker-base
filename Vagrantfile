# -*- mode: ruby -*-
# vi: set ft=ruby :

version = `curl -s https://api.github.com/repos/pagodabox/nanobox-boot2docker/releases/latest | json name`.strip

$wait = <<SCRIPT
echo "Waiting for docker sock file"
while [ ! -S /var/run/docker.sock ]; do
  sleep 1
done
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box     = "nanobox/boot2docker"
  config.vm.box_url = "https://github.com/pagodabox/nanobox-boot2docker/releases/download/#{version}/nanobox-boot2docker.box"

  config.vm.synced_folder ".", "/vagrant"

  # wait for docker to be running
  config.vm.provision "shell", inline: $wait

  # Add docker credentials
  config.vm.provision "file", source: "~/.dockercfg", destination: "/root/.dockercfg"

  # Build base image
  config.vm.provision "shell", inline: "docker build -t #{ENV['docker_user']}/base /vagrant"

  # Publish image to dockerhub
  config.vm.provision "shell", inline: "docker push #{ENV['docker_user']}/base"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "1024", "--ioapic", "on"]
  end

end
