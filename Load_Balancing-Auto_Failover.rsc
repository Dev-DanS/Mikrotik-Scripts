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

    # Check if WAN interfaces are disabled and unreachable
    :local wan1Disabled [/interface get $wan1 disabled]
    :local wan2Disabled [/interface get $wan2 disabled]
    :if (($wan1Disabled = false) && ([/ping $target1 count=1] = 3)) do={
        /interface set $wan1 disabled=yes
    }
    :if (($wan2Disabled = false) && ([/ping $target2 count=1] = 3)) do={
        /interface set $wan2 disabled=yes
    }

    # Enable/disable WAN interfaces for load balancing
    :if (($wan1Disabled = true) || ($wan2Disabled = true)) do={
        /interface bonding disable
    } else={
        /interface bonding set mode=balance-rr primary=$wan1 slaves=$wan2
    }
}
