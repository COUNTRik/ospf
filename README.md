# ospf

Настроим динамическую маршрутизацию с помощью FRR.

Дано три роутера *router1, router2, router3* объединенные в сеть в виде треугольника со следующими параметрами

    router1 => [
               {ip: '10.10.10.1', eth: 1, netmask: "255.255.255.252", virtualbox__intnet: "vlan10"},
               {ip: '10.10.30.1', eth: 2, netmask: "255.255.255.252", virtualbox__intnet: "vlan30"},
              ]   

    router2 => [
               {ip: '10.10.10.2', eth: 1, netmask: "255.255.255.252", virtualbox__intnet: "vlan10"},
               {ip: '10.10.20.2', eth: 2, netmask: "255.255.255.252", virtualbox__intnet: "vlan20"},
              ]

    router3 => [
               {ip: '10.10.30.2', eth: 1, netmask: "255.255.255.252", virtualbox__intnet: "vlan30"},
               {ip: '10.10.20.1', eth: 2, netmask: "255.255.255.252", virtualbox__intnet: "vlan20"},
              ]

Запустив стенд *vagrant up* будет установлен *frr*, включен *ip forward*, отключен *rp_filter*.

Проверим *rp_filter* на всякий случай

      [root@router1 vagrant]# sysctl -a | grep rp_filter
      sysctl: net.ipv4.conf.all.arp_filter = 0
      net.ipv4.conf.all.rp_filter = 0
      net.ipv4.conf.default.arp_filter = 0
      net.ipv4.conf.default.rp_filter = 1
      net.ipv4.conf.eth0.arp_filter = 0
      net.ipv4.conf.eth0.rp_filter = 0
      net.ipv4.conf.eth1.arp_filter = 0
      net.ipv4.conf.eth1.rp_filter = 0
      net.ipv4.conf.eth2.arp_filter = 0
      net.ipv4.conf.eth2.rp_filter = 0
      net.ipv4.conf.lo.arp_filter = 0
      net.ipv4.conf.lo.rp_filter = 0
      reading key "net.ipv6.conf.all.stable_secret"

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


## Показать асимметричную маршрутизацию

Поменяем значение *cost* в конфигурационных файлах /etc/frr/ospfd.conf в *router1*, *router2*, *router3*. Можно на хосте поменять значения в конфигах в папке *config* и запустить *frr.yml*. Он заменит конфиги и перезапустит *frr*. Получится такая схема *... router1 > cost 50 < router2 > cost 150 < router3 > cost 75 < router1 ...*

*router1*

      hostname ospfd
      password zebra

      interface eth1
        ip ospf mtu-ignore
        ip ospf network point-to-point
        ip ospf cost 50
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      interface eth2
        ip ospf mtu-ignore
        ip ospf network point-to-point
        ip ospf cost 75
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      router ospf
        !router-id 1
        !network 192.168.1.1/24 area 0
        !network 192.168.2.2/24 area 0
        !network 192.168.3.3/24 area 0
        network 10.10.10.0/30 area 0
        !network 10.10.20.0/30 area 0
        network 10.10.30.0/30 area 0

        neighbor 10.10.10.2
        neighbor 10.10.30.2

      log stdout


*router2*

      hostname ospfd
      password zebra

      interface eth1
        ip ospf mtu-ignore
        ip ospf network point-to-point
        ip ospf cost 50
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      interface eth2
        ip ospf mtu-ignore
        ip ospf network point-to-point
        ip ospf cost 150
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      router ospf
        !router-id 2
        !network 192.168.1.1/24 area 0
        !network 192.168.2.2/24 area 0
        !network 192.168.3.3/24 area 0
        network 10.10.10.0/30 area 0
        network 10.10.20.0/30 area 0
        !network 10.10.30.0/30 area 0

        neighbor 10.10.10.1
        neighbor 10.10.20.1

      log stdout

*router3*

      hostname ospfd
      password zebra

      interface eth1
        ip ospf mtu-ignore
        ip ospf network point-to-point
        ip ospf cost 75
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      interface eth2
        ip ospf mtu-ignore
        ip ospf network point-to-point
        ip ospf cost 150
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      router ospf
        !router-id 3
        !network 192.168.1.1/24 area 0
        !network 192.168.2.2/24 area 0
        !network 192.168.3.3/24 area 0
        !network 10.10.10.0/30 area 0
        network 10.10.20.0/30 area 0
        network 10.10.30.0/30 area 0

        neighbor 10.10.30.1
        neighbor 10.10.20.2

      log stdout


Проверяем асимметричность маршрута.

*router1*

      [root@router1 vagrant]# ping -c 1 10.10.20.1
      PING 10.10.20.1 (10.10.20.1) 56(84) bytes of data.
      64 bytes from 10.10.20.1: icmp_seq=1 ttl=64 time=0.996 ms

      --- 10.10.20.1 ping statistics ---
      1 packets transmitted, 1 received, 0% packet loss, time 0ms
      rtt min/avg/max/mdev = 0.996/0.996/0.996/0.000 ms


*router2*

      [root@router2 vagrant]# tcpdump -nvvv -i any icmp
      tcpdump: listening on any, link-type LINUX_SLL (Linux cooked), capture size 262144 bytes
      12:54:19.991795 IP (tos 0x0, ttl 64, id 6688, offset 0, flags [DF], proto ICMP (1), length 84)
          10.10.10.1 > 10.10.20.1: ICMP echo request, id 7065, seq 1, length 64
      12:54:19.991825 IP (tos 0x0, ttl 63, id 6688, offset 0, flags [DF], proto ICMP (1), length 84)
          10.10.10.1 > 10.10.20.1: ICMP echo request, id 7065, seq 1, length 64

*router2*

      [root@router3 vagrant]# tcpdump -nvvv -i eth1 icmp
      tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
      12:54:19.991716 IP (tos 0x0, ttl 64, id 12199, offset 0, flags [none], proto ICMP (1), length 84)
          10.10.20.1 > 10.10.10.1: ICMP echo reply, id 7065, seq 1, length 64


## Показать симметричную маршрутизацию при изменении стоимсти маршрутов

Как я понимаю достаточно оставить дешевый маршрут на одной стороне нашего треугольник *... router1 > cost 50 < router2 > default 100 < router3 > default 100 < router1 ...*


      hostname ospfd
      password zebra

      interface eth1
        ip ospf mtu-ignore
        ip ospf network point-to-point
        ip ospf cost 50
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      interface eth2
        ip ospf mtu-ignore
        ip ospf network point-to-point
        !ip ospf cost 100
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      router ospf
        !router-id 1
        !network 192.168.1.1/24 area 0
        !network 192.168.2.2/24 area 0
        !network 192.168.3.3/24 area 0
        network 10.10.10.0/30 area 0
        !network 10.10.20.0/30 area 0
        network 10.10.30.0/30 area 0

        neighbor 10.10.10.2
        neighbor 10.10.30.2

      log stdout


      hostname ospfd
      password zebra

      interface eth1
        ip ospf mtu-ignore
        ip ospf network point-to-point
        ip ospf cost 50
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      interface eth2
        ip ospf mtu-ignore
        ip ospf network point-to-point
        !ip ospf cost 100
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      router ospf
        !router-id 2
        !network 192.168.1.1/24 area 0
        !network 192.168.2.2/24 area 0
        !network 192.168.3.3/24 area 0
        network 10.10.10.0/30 area 0
        network 10.10.20.0/30 area 0
        !network 10.10.30.0/30 area 0

        neighbor 10.10.10.1
        neighbor 10.10.20.1

      log stdout


      hostname ospfd
      password zebra

      interface eth1
        ip ospf mtu-ignore
        ip ospf network point-to-point
        !ip ospf cost 75
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      interface eth2
        ip ospf mtu-ignore
        ip ospf network point-to-point
        !ip ospf cost 100
        ip ospf hello-interval 5
        ip ospf dead-interval 10

      router ospf
        !router-id 3
        !network 192.168.1.1/24 area 0
        !network 192.168.2.2/24 area 0
        !network 192.168.3.3/24 area 0
        !network 10.10.10.0/30 area 0
        network 10.10.20.0/30 area 0
        network 10.10.30.0/30 area 0

        neighbor 10.10.30.1
        neighbor 10.10.20.2

      log stdout

В этом случае маршрут остается симметричным. В других топологиях и схемах в зависимости от количества узлов маршрутизация может быть разной, поэтому лучше проверить по какому маршруту проходят пакеты.