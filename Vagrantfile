# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Debian box
  config.vm.box = "bento/debian-10.4"
  config.vm.hostname = "abnib-birthdays-vm"

  # Create a forwarded port mapping
  config.vm.network "forwarded_port", guest: 4567, host: 4567

  # Synchronise source folder to VM
  config.vm.synced_folder ".", "/home/vagrant/abnib-birthdays"

  # As user: install RVM
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    curl -sSL https://get.rvm.io | bash -s $1
  SHELL
  # Install Ruby and gems, ensuring we have an execjs
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    rvm install #{File::read('.ruby-version').strip} --default
    echo "cd ~/abnib-birthdays && bundle" | bash --login
  SHELL

  # Every 'up', launch Middleman
  config.trigger.after :up do |trigger|
    trigger.name = "Launch Middleman"
    trigger.run_remote = { privileged: false, inline: 'echo "cd ~/abnib-birthdays && middleman" | bash --login' }
  end
end
