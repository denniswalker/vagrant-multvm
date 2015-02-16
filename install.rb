#!/usr/bin/env ruby
# encoding: utf-8
require 'FileUtils'

# Script to download vagrant, virtualbox, chefdk and vagrant plugins.
# Detects if apps and plugins are already installed and at correct version.
class DevSetup
  attr_accessor :packages, :download_path, :vb_plugins

  @packages = [
    {
      name: 'Virtualbox',
      version: '4.3.20',
      version_check: 'vboxmanage -v',
      url: 'http://download.virtualbox.org/virtualbox/4.3.20',
      dmg: 'VirtualBox-4.3.20-96996-OSX.dmg',
      volume: 'Virtualbox',
      pkg: 'Virtualbox.pkg'
    },
    {
      name: 'Vagrant',
      version: '1.6.5',
      version_check: 'vagrant -v',
      url: 'https://dl.bintray.com/mitchellh/vagrant',
      dmg: 'vagrant_1.6.5.dmg',
      volume: 'Vagrant',
      pkg: 'Vagrant.pkg'
    },
    {
      name: 'ChefDK',
      version: '3.2',
      version_check: 'berks -v',
      url: 'https://opscode-omnibus-packages.s3.amazonaws.com/mac_os_x/10.8/x86_64',
      dmg: 'chefdk-0.3.5-1.dmg',
      volume: 'Chef\ Development\ Kit',
      pkg: 'chefdk-0.3.5-1.pkg'
    }
  ]

  @download_path = File.expand_path('~/Downloads')

  @vb_plugins = %w(vagrant-vbox-snapshot vagrant-berkshelf vagrant-omnibus)

  def self.install_pkg(volume, pkg, name)
    installer = "/Volumes/#{volume}/#{pkg}"
    if File.exist?(installer)
      puts "Installing #{name}"
      `sudo installer -pkg #{installer} -target /`
    else
      puts "Couldn't find #{installer} to open."
    end
  end

  def self.installed?(check, version)
    result = `#{check}`
    if result.match(version)
      true
    else
      false
    end
  end

  def self.open_file(dmg)
    if File.exist?("#{@download_path}/#{dmg}")
      puts "Opening #{dmg}"
      `hdiutil attach #{@download_path}/#{dmg}`
    else
      puts "Couldn't find #{download_path}/#{dmg} to open."
    end
  end

  def self.download_file(url, dmg)
    begin
      puts "Downloading #{url}/#{dmg}"
      puts "#{@download_path}/#{dmg}"
      `curl -o #{@download_path}/#{dmg} -OL #{url}/#{dmg}`
    end
    open_file(dmg)
  end

  def self.cleanup(volume, dmg)
    puts "cleaning up #{volume}"
    ::FileUtils.rm_f("#{@download_path}/#{dmg}")
    `hdiutil eject /Volumes/#{volume}`
  end

  def self.create_dev_json
    ::FileUtils.cp('dev.json.sample', 'dev.json') unless File.exist?('dev.json')
    puts 'Now edit your settings in the dev.json file and run "vagrant up".'
  end

  def self.install_plugins
    puts 'Installing vagrant plugins.'
    already_installed = `vagrant plugin list`
    @vb_plugins.each do |plugin|
      if already_installed.match(plugin)
        puts "#{plugin} is alread installed."
      else
        `vagrant plugin install #{plugin}`
      end
    end
  end

  def self.install_packages
    @packages.each do |package|
      if installed? package[:version_check], package[:version]
        puts "#{package[:name]} #{package[:version]} already installed."
      else
        download_file package[:url], package[:dmg]
        install_pkg package[:volume], package[:pkg], package[:name]
        cleanup package[:volume], package[:dmg]
      end
    end
  end

  def self.install_gems
    puts 'Installing any missing gems...'
    bundle_exists = `bundle -v`
    `gem install bundle` unless bundle_exists.match('Bundler version')
    `bundle`
  end

  def self.main
    install_packages
    install_plugins
    install_gems
    create_dev_json
  end
end

SayDevSetup.main
