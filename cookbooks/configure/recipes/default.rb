# Cookbook Name:: configure
# Recipe:: default
#
# Copyright 2013, Example Com
#
#

# execute 'DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade'

include_recipe "python"
include_recipe "vim"
package "git"
package "s3cmd"

pips = [
  "ipython",
  "flask",
  "Frozen-Flask",
  "markdown2",
  "pygments",
  "PyYAML",
  "boto",
  "pyramid",
  "webtest",
  "deform",
  "sqlalchemy"
]
pips.each do |p|
  python_pip p do
    action :install
  end
end

directories = [
  "/home/vagrant/blog/",
  "/home/vagrant/.ssh",
  "/home/vagrant/.aws",
  "/home/vagrant/bin" 
]
directories.each do |d|
  directory d do
    owner "vagrant"
    group "vagrant"
    mode 00755
    recursive true
  end
end

remote_file "/tmp/Python-3.3.0.tgz" do
  source "http://python.org/ftp/python/3.3.0/Python-3.3.0.tgz"
  action :create_if_missing
end

execute "install Python3.3 from source" do
  command <<-EOC
    cd /tmp;
    tar xvzf Python-3.3.0.tgz;
    ./configure
    make
    make install
    curl -O http://python-distribute.org/distribute_setup.py
    python3.3 distribute_setup.py
  EOC
end

remote_file "/home/vagrant/bin/vcprompt" do
  source "https://raw.github.com/djl/vcprompt/master/bin/vcprompt"
  action :create_if_missing
  owner "vagrant"
  group "vagrant"
  mode 00755
end

cookbook_file "/home/vagrant/.profile" do
  source "bash_profile"
  owner "vagrant"
  group "vagrant"
  mode 00755
end

include_recipe "vim"
cookbook_file "/home/vagrant/.vimrc" do
  source "vimrc"
  owner "vagrant"
  group "vagrant"
  mode 00755
end

gitbag = data_bag_item("git", "ssh_keys")
ssh_public = gitbag["_default"]["public_key"]
ssh_private = gitbag["_default"]["private_key"]
known_hosts = gitbag["_default"]["known_hosts"]
awsbag = data_bag_item("aws", "aws_keys")
access_key = awsbag["_default"]["access_key"]
secret_key = awsbag["_default"]["secret_key"]

file "/home/vagrant/.ssh/id_rsa.pub" do
  content ssh_public
  owner "vagrant"
  group "vagrant"
  mode 00600
end

file "/home/vagrant/.ssh/id_rsa" do
  content ssh_private
  owner "vagrant"
  group "vagrant"
  mode 00600
end

file "/home/vagrant/.ssh/known_hosts" do
  content known_hosts
  owner "vagrant"
  group "vagrant"
  mode 00600
end

file "/home/vagrant/.aws/access_key" do
  content access_key
  owner "vagrant"
  group "vagrant"
  mode 00600
end

file "/home/vagrant/.aws/secret_key" do
  content secret_key
  owner "vagrant"
  group "vagrant"
  mode 00600
end

template "/home/vagrant/.s3cfg" do
  source "s3cfg.erb"
  mode  00400
  owner "vagrant"
  group "vagrant"
  variables({
    :access_key => access_key,
    :secret_key => secret_key
  })
end

cookbook_file "/home/vagrant/.gitconfig" do
  source "gitconfig"
  owner "vagrant"
  group "vagrant"
  mode 00755
end

git "/home/vagrant/blog" do
  repository "git@github.com:Version2beta/version2beta.git"
  reference "master"
  user "vagrant"
  group "vagrant"
  action :sync
end
