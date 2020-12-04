# ospf

Настроим динамическую маршрутизацию с помощью FRR.

Дано три роутера *router1, router2, router3* объединенные в сеть в виде треугольника со следующими параметрами

	router1 => {
		{ip: '10.10.0.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-1"},
		{ip: '10.30.0.1', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "router-3"},
	}

	router2 => {
		{ip: '10.10.0.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-1"},
		{ip: '10.20.0.2', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "router-2"},
	}

	router3 => {
		{ip: '10.20.0.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-2"},
		{ip: '10.30.0.2', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "router-3"},
	}

Запустив стенд *vagrant up* будет установлен *frr* и включен *ip forward*.