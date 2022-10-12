# DROP FRAGMENTS
iptables -A INPUT -f -j DROP

# DROP XMAS PACKETS
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# DROP NULL PACKETS
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# DROP EXCESSIVE TCP RST PACKETS
iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

# DROP ALL INVALID PACKETS
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP

# DROP RFC1918 PACKETS
iptables -A INPUT -s 10.0.0.0/8 -j DROP
iptables -A INPUT -s 172.16.0.0/12 -j DROP
iptables -A INPUT -s 192.168.0.0/16 -j DROP

# DROP SPOOFED PACKETS
iptables -A INPUT -s 169.254.0.0/16 -j DROP
iptables -A INPUT -s 127.0.0.0/8 -j DROP
iptables -A INPUT -s 224.0.0.0/4 -j DROP
iptables -A INPUT -d 224.0.0.0/4 -j DROP
iptables -A INPUT -s 240.0.0.0/5 -j DROP
iptables -A INPUT -d 240.0.0.0/5 -j DROP
iptables -A INPUT -s 0.0.0.0/8 -j DROP
iptables -A INPUT -d 0.0.0.0/8 -j DROP
iptables -A INPUT -d 239.255.255.0/24 -j DROP
iptables -A INPUT -d 255.255.255.255 -j DROP

# ICMP SMURF ATTACKS + RATE LIMIT THE REST
iptables -A INPUT -p icmp --icmp-type address-mask-request -j DROP
iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
iptables -A INPUT -p icmp --icmp-type router-solicitation -j DROP
iptables -A INPUT -p icmp -m limit --limit 2/second -j ACCEPT

# DROP SYN-FLOOD PACKETS
iptables -A INPUT -p tcp -m state --state NEW -m limit --limit 50/second --limit-burst 50 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -j DROP
