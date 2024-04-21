# Define WAN interfaces
:local wan1 "ether1"
:local wan2 "ether2"

# Define health check targets
:local target1 "8.8.8.8"
:local target2 "1.1.1.1"

# Health check function
:local healthCheck do={
    :local loss1 [/ping $target1 count=3]
    :local loss2 [/ping $target2 count=3]

    :if (($loss1 = 3) && ($loss2 = 3)) do={
        /interface set $wan1 disabled=yes
        /interface set $wan2 disabled=yes
    } else={
        /interface set $wan1 disabled=($loss1 = 3)
        /interface set $wan2 disabled=($loss2 = 3)
    }
}

# Main script
:forever do={
    :delay 10s
    $healthCheck

    # Calculate active WAN interfaces
    :local wan1Status [/interface get $wan1 disabled]
    :local wan2Status [/interface get $wan2 disabled]

    # Enable/disable WAN interfaces for load balancing
    :if (($wan1Status = false) && ($wan2Status = false)) do={
        /interface bonding set mode=balance-rr primary=$wan1 slaves=$wan2
    } else={
        /interface bonding disable
    }

    # Check if disabled interface is now reachable
    :if (($wan1Status = true) && ([/ping $target1 count=1] != 3)) do={
        /interface set $wan1 disabled=no
    }
    :if (($wan2Status = true) && ([/ping $target2 count=1] != 3)) do={
        /interface set $wan2 disabled=no
    }
}
