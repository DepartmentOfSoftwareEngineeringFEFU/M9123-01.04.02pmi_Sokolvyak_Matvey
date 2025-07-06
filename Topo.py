from mininet.topo import Topo
from mininet.net import Mininet
from mininet.cli import CLI
from mininet.node import RemoteController, OVSSwitch  # Добавлен OVSSwitch
import networkx as nx
import matplotlib.pyplot as plt
import math
import os
import time
import subprocess


class MyTopo(Topo):
    def build(self):
        h1 = self.addHost('h1')
        h2 = self.addHost('h2')
        h3 = self.addHost('h3')
        h4 = self.addHost('h4')
        h5 = self.addHost('h5')
        h6 = self.addHost('h6')
        h7 = self.addHost('h7')
        h8 = self.addHost('h8')
        h9 = self.addHost('h9')
        h10 = self.addHost('h10')
        h11 = self.addHost('h11')
        # Свитчи
        s1 = self.addSwitch('s1', protocols='OpenFlow13')
        s2 = self.addSwitch('s2', protocols='OpenFlow13')
        s3 = self.addSwitch('s3', protocols='OpenFlow13')
        s4 = self.addSwitch('s4', protocols='OpenFlow13')
        s5 = self.addSwitch('s5', protocols='OpenFlow13')

        # IDS хост
        ids = self.addHost('ids', ip='10.0.0.100')
        self.addLink(ids, s1)

        # Связи с VLAN и портовой безопасностью
        self.addLink(h1, s1, params1={'vlan': '100'}, 
                   **{'port_security': 'true', 'max_mac': '1', 'sticky_mac': 'true'})
        self.addLink(h2, s2, params1={'vlan': '100'}, 
                   **{'port_security': 'true', 'max_mac': '1', 'sticky_mac': 'true'})
        
        self.addLink(h3, s3)
        self.addLink(h4, s3)
        self.addLink(h5, s3)
        self.addLink(h6, s4)
        self.addLink(h7, s4)
        self.addLink(h8, s4)
        self.addLink(h9, s5)
        self.addLink(h10, s5)
        self.addLink(h11, s5)

        self.addLink(s1, s2)
        self.addLink(s3, s4)
        self.addLink(s3, s5)
        self.addLink(s4, s5)
        self.addLink(s2, s4)


def setup_security(net):
    # Настройка аудита
    for switch in net.switches:
        switch.cmd("sysctl -w net.netfilter.nf_log.2=nf_log_ipv4")
        switch.cmd("sysctl -w kernel.printk='7 7 7 7'")
        switch.cmd("modprobe nf_log_ipv4")
        switch.cmd("iptables -A INPUT -j LOG --log-prefix 'NETFILTER_INPUT: '")
        switch.cmd("iptables -A OUTPUT -j LOG --log-prefix 'NETFILTER_OUTPUT: '")
        switch.cmd("iptables -A FORWARD -j LOG --log-prefix 'NETFILTER_FORWARD: '")

    # ACL правила
    for switch in net.switches:
        switch.cmd("ovs-ofctl add-flow {} priority=40000,ip,nw_src=10.0.0.1/32,actions=drop".format(switch.name))
        switch.cmd("ovs-ofctl add-flow {} priority=30000,arp,arp_op=1,nw_dst=10.0.0.1/32,actions=drop".format(switch.name))

    # Настройка SSH
    for host in net.hosts:
        host.cmd('/usr/sbin/sshd -D &')
        host.cmd('echo "root:strongpassword" | chpasswd')
        host.cmd('sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/" /etc/ssh/sshd_config')
        host.cmd('service ssh restart')
 
    # Настройка IDS
    net.get('ids').cmd('suricata -D -c /etc/suricata/suricata.yaml -i ids-eth0')
    
    # Настройка sFlow
    for switch in net.switches:
        switch.cmd('ovs-vsctl -- --id=@sflow create sflow agent='+switch.name+\
                  ' target=\\"127.0.0.1:6343\\" sampling=10 polling=20 --'+\
                  ' -- set bridge '+switch.name+' sflow=@sflow')


def visualize_topology(net):
    G = nx.Graph()
    G.add_node("c0")
    for node in net.hosts + net.switches:
        G.add_node(node.name)
    
    for link in net.links:
        G.add_edge(link.intf1.node.name, link.intf2.node.name)
    
    pos = {}
    pos["c0"] = (0, 0)
    
    switch_count = len(net.switches)
    radius_switches = 2
    for i, switch in enumerate(net.switches):
        angle = 2 * math.pi * i / switch_count
        pos[switch.name] = (radius_switches * math.cos(angle), radius_switches * math.sin(angle))
    
    host_count = len(net.hosts)
    radius_hosts = 4
    for i, host in enumerate(net.hosts):
        angle = 2 * math.pi * i / host_count
        pos[host.name] = (radius_hosts * math.cos(angle), radius_hosts * math.sin(angle))
    
    node_colors = []
    for node in G.nodes():
        if node == "c0":
            node_colors.append('mistyrose')
        elif node.startswith('s'):
            node_colors.append('lightgreen')
        else:
            node_colors.append('lightblue')
    
    plt.figure(figsize=(10, 10))
    nx.draw_networkx_nodes(G, pos, node_color=node_colors, node_size=800)
    nx.draw_networkx_edges(G, pos, width=2)
    nx.draw_networkx_labels(G, pos, font_size=10, font_weight='bold')
    plt.title("Network Topology")
    plt.axis('equal')
    plt.axis('off')
    plt.tight_layout()
    plt.savefig("topology.png", dpi=300)
    plt.show()


if __name__ == '__main__':
    # Проверка что Mininet - это действительно класс, а не строка
    print("Mininet type:", type(Mininet))  # Должно быть <class 'type'>
    
    topo = MyTopo()
    
    # Явно указываем класс switch
    net = Mininet(topo=topo,
                 controller=None,
                 switch=OVSSwitch,  # Явное указание класса switch
                 autoSetMacs=True,
                 autoStaticArp=True)
    
    # Добавляем контроллер
    net.addController('c0',
                    controller=RemoteController,
                    ip='127.0.0.1',
                    port=6653,
                    protocols='OpenFlow13')
    
    net.start()
    setup_security(net)
    
    h1 = net.get('h1')
    h1.cmd("sudo -u postgres psql -f cars_data.sql")
    visualize_topology(net)
    CLI(net)
    net.stop()


