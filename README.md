# ospf

Настроим динамическую маршрутизацию с помощью FRR.

Дано три роутера *router1, router2, router3* объединенные в сеть в виде треугольника со следующими параметрами

:router1 => [
             {ip: '10.10.10.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "vlan10"},
             {ip: '10.10.30.1', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "vlan30"},
             {ip: '192.168.1.1', adapter: 4, netmask: "255.255.255.0", virtualbox__intnet: "area-1"},
            ]   

:router2 => [
             {ip: '10.10.10.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "vlan10"},
             {ip: '10.10.20.2', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "vlan20"},
             {ip: '192.168.2.2', adapter: 4, netmask: "255.255.255.0", virtualbox__intnet: "area-2"},
            ]

:router3 => [
             {ip: '10.10.30.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "vlan30"},
             {ip: '10.10.20.1', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "vlan20"},
             {ip: '192.168.3.3', adapter: 4, netmask: "255.255.255.0", virtualbox__intnet: "area-3"},
            ]

Запустив стенд *vagrant up* будет установлен *frr*, включен *ip forward*, отключен *rp_filter*.
После запускаем playbook *frr.yml*, который скопирует конфиги в роутеры и перезапустит *frr*.