# -*- mode: ruby -*-
# vim: set ft=ruby :
# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {

:router1 => {
      :box_name => "centos/7",
      :net => [
                 {ip: '10.10.10.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "vlan10"},
                 {ip: '10.10.30.1', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "vlan30"},
                 {ip: '192.168.1.1', adapter: 4, netmask: "255.255.255.0", virtualbox__intnet: "area-1"},
              ]   
},

:router2 => {
      :box_name => "centos/7",
      :net => [
                 {ip: '10.10.10.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "vlan10"},
                 {ip: '10.10.20.2', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "vlan20"},
                 {ip: '192.168.2.2', adapter: 4, netmask: "255.255.255.0", virtualbox__intnet: "area-2"},
              ]
},

:router3 => {
      :box_name => "centos/7",
      :net => [
                 {ip: '10.10.30.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "vlan30"},
                 {ip: '10.10.20.1', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "vlan20"},
                 {ip: '192.168.3.3', adapter: 4, netmask: "255.255.255.0", virtualbox__intnet: "area-3"},
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
        
        box.vm.provision "ansible" do |ansible|
          ansible.playbook = "ansible/playbook/provision.yml"
        end
                
    end

  end
    
end