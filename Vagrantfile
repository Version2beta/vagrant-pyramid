# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.forward_port 8000, 8000, { :auto => true }
  config.vm.share_folder "v-data", "/home/vagrant/host_shared", "./shared"
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.data_bags_path = "data_bags"
    chef.add_recipe "apt"
    chef.add_recipe "build-essential"
    chef.add_recipe "ohai"
    chef.add_recipe "configure"
  end
end
