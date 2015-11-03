# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # This box was built with https://github.com/boxcutter/windows
  config.vm.box = "eval-win2012r2-standard-ssh-nocm-1.0.4"

  config.vm.provision "shell", inline: <<-SHELL
    (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
    Install-Module Psake
    Install-Module Pester 
  SHELL
end
