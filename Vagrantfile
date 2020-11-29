# -*- mode: ruby -*-
# vim: set ft=ruby :
# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {

:router1 => {
      :box_name => "centos/7",
      :net => [
                 {ip: '10.10.0.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-1"},
                 {ip: '10.30.0.1', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "router-3"},
              ]   
},

:router2 => {
      :box_name => "centos/7",
      :net => [
                 {ip: '10.10.0.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-1"},
                 {ip: '10.20.0.2', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "router-2"},
              ]
},

:router3 => {
      :box_name => "centos/7",
      :net => [
                 {ip: '10.20.0.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-2"},
                 {ip: '10.30.0.2', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "router-3"},
              ]
},
  
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end
        
        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end
        
        # box.vm.provision "ansible" do |ansible|
        #   ansible.playbook = "ansible/playbook/provision.yml"
        # end
                
    end

  end
    
end