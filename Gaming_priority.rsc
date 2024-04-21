# Define gaming traffic
:local gamingPorts "27015,27016"  # Update with your gaming ports

# Create a layer-7 protocol for gaming traffic
/ip firewall layer7-protocol add name=gaming regexp="^.{0,4}[\x00-\x7F][\x00-\x7F][\x00-\x7F][\x00-\x7F].*[\x00-\x7F](\x0A|\x0D)?\x0A\x0D{0,1}\x0A\x0D{0,1}.*\x0A\x0D{0,1}\x0A\x0D{0,1}" 

# Mark packets from gaming ports
/ip firewall mangle add action=mark-packet chain=forward comment="Mark gaming packets" layer7=gaming new-packet-mark=gaming passthrough=no

# Create a queue tree for gaming traffic
/queue tree add name="gaming" parent=global priority=1 limit-at=0 max-limit=0 packet-mark=gaming
