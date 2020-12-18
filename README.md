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
Маршрутизация по протоколу OSPF построена.

      [root@router1 vagrant]# ip route
      default via 10.0.2.2 dev eth0 proto dhcp metric 100 
      10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
      10.10.10.0/30 dev eth1 proto kernel scope link src 10.10.10.1 metric 101 
      10.10.20.0/30 proto 188 metric 20 
            nexthop via 10.10.10.2 dev eth1 weight 1 
            nexthop via 10.10.30.2 dev eth2 weight 1 
      10.10.30.0/30 dev eth2 proto kernel scope link src 10.10.30.1 metric 102 
      192.168.1.0/24 dev eth3 proto kernel scope link src 192.168.1.1 metric 103 
      192.168.2.0/24 via 10.10.10.2 dev eth1 proto 188 metric 20 
      192.168.3.0/24 via 10.10.30.2 dev eth2 proto 188 metric 20 
       

## Показать асимметричную маршрутизацию

Поменяем значение *cost* в конфигурационных файлах /etc/frr/ospfd.conf в *router1* и в *router2*. Можно на хосте поменять значения в конфигах в папке *config* и запустить *frr.yml*. Он заменит конфиги и перезапустит *frr*.

*router1*

      hostname ospfd
      password zebra

      interface eth1
        ip ospf mtu-ignore
        !ip ospf network point-to-point
        ip ospf cost 50
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      interface eth2
        ip ospf mtu-ignore
        !ip ospf network point-to-point
        !ip ospf cost 200
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      router ospf
        !router-id 1
        network 192.168.1.1/24 area 0
        !network 192.168.2.2/24 area 0
        !network 192.168.3.3/24 area 0
        network 10.10.10.0/30 area 0
        !network 10.10.20.0/30 area 0
        network 10.10.30.0/30 area 0

        !neighbor 10.10.10.2
        !neighbor 10.10.30.2

      log stdout

*router2*

      hostname ospfd
      password zebra

      interface eth1
        ip ospf mtu-ignore
        !ip ospf network point-to-point
        ip ospf cost 50
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      interface eth2
        ip ospf mtu-ignore
        !ip ospf network point-to-point
        !ip ospf cost 50
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      router ospf
        !router-id 2
        !network 192.168.1.1/24 area 0
        network 192.168.2.2/24 area 0
        !network 192.168.3.3/24 area 0
        network 10.10.10.0/30 area 0
        network 10.10.20.0/30 area 0
        !network 10.10.30.0/30 area 0

        !neighbor 10.10.10.1
        !neighbor 10.10.20.1

      log stdout

Проверяем асимметричность маршрута.

Запустим пинг на router3

      [root@router3 vagrant]# ping -c 1 10.10.10.1
      PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
      64 bytes from 10.10.10.1: icmp_seq=1 ttl=63 time=1.15 ms

      --- 10.10.10.1 ping statistics ---
      1 packets transmitted, 1 received, 0% packet loss, time 0ms
      rtt min/avg/max/mdev = 1.153/1.153/1.153/0.000 ms

