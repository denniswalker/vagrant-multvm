# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'json'
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Create a gitignored dev.json file if it doesnt already exist.
  # Load settings from there having to do with the task at hand.
  FileUtils.cp('dev.json.sample', 'dev.json') unless File.exist?('dev.json')
  local_settings = JSON.parse(File.read('dev.json'))
  puts 'Settings found in dev.json:'
  puts JSON.pretty_generate(local_settings)

  local_settings.each do |box|
    config.vm.define box['name'] do |config|
      if box['distro'] == 'centos'
        config.vm.box = 'chef/centos-6.5'
      elsif box['distro'] == 'ubuntu'
        config.vm.box = 'ubuntu/trusty64'
      end

      config.vm.network 'private_network', ip: box['ip']
      config.vm.network 'public_network', bridge: 'en1: Wi-Fi (AirPort)'
      config.vm.hostname = box['name']

      config.omnibus.chef_version = '11.16.0'
      config.berkshelf.enabled = true
      config.berkshelf.berksfile_path = './Berksfile'

      config.vm.provider 'virtualbox' do |vb|
        # vb.gui = true
        vb.customize ['modifyvm', :id, '--memory', box['mem']] if box['mem']
        vb.customize ['modifyvm', :id, '--cpus', box['cpus']] if box['cpus']
      end

      config.vm.provision 'chef_solo' do |chef|
        # chef.roles_path = 'roles'
        chef.data_bags_path = 'data_bags'
        chef.environments_path = 'environments'
        chef.environment = 'vagrant'

        chef.verbose_logging = true
        chef.log_level = 'debug'

        # Specify which cookbooks and recipes to run in the dev.json file.
        chef.run_list = box['chef']['run_list']
        chef.json = box['chef']['json']
      end
    end
  end
end
