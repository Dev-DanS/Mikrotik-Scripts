# Create firewall mangle rules to mark browsing and gaming traffic
/ip firewall mangle
add action=mark-connection chain=prerouting dst-port=80,443 new-connection-mark=browsing_conn passthrough=yes protocol=tcp comment="Mark browsing connections"
add action=mark-packet chain=prerouting connection-mark=browsing_conn new-packet-mark=browsing_packet passthrough=yes comment="Mark browsing packets"
add action=mark-connection chain=prerouting dst-port=27015-27030,3478,4379-4380 new-connection-mark=gaming_conn passthrough=yes protocol=udp comment="Mark gaming connections"
add action=mark-packet chain=prerouting connection-mark=gaming_conn new-packet-mark=gaming_packet passthrough=yes comment="Mark gaming packets"

# Create separate routing tables for browsing and gaming
/ip route
add distance=1 gateway=YOUR_BROWSING_GATEWAY routing-mark=browsing
add distance=2 gateway=YOUR_GAMING_GATEWAY routing-mark=gaming

# Apply routing marks to packets
/ip firewall mangle
add action=mark-routing chain=prerouting new-routing-mark=browsing passthrough=no packet-mark=browsing_packet comment="Route browsing packets"
add action=mark-routing chain=prerouting new-routing-mark=gaming passthrough=no packet-mark=gaming_packet comment="Route gaming packets"

# Apply routing rules
/ip route rule
add dst-address-type=!local routing-mark=browsing table=browsing comment="Browsing traffic"
add dst-address-type=!local routing-mark=gaming table=gaming comment="Gaming traffic"
