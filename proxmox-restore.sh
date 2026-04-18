#!/bin/bash 

# To restore more machines add the search term to DEFAULT_ARGUMENTS near the 
# bottom of this script or rerun this script with the search terms you want 
# passed as positional arguments where the search term refers to the 
# VM/Container name. 
# Example: DEFAULT_ARGUMENTS=(ubu ubudesk) 
# Example: proxmox-restore.sh ubu ubudesk 

reset_guests() { 
    local SEARCH="$1" 
    local CMD="$2" 
    
    # Get matching IDs 
    for ID in $($CMD list | grep -Ei "$SEARCH[0-9]+" | tail -n +1 | awk '{print $1}'); do 
        
        # Extract status (fixed-width column) 
        local STATUS 
        [ "$CMD" == "pct" ] && STATUS=$($CMD list | grep -w "$ID" | tail -n +1 | awk '{print $2}') || STATUS=$($CMD list | grep -w "$ID" | awk '{ 
            s = substr($0, 32, 10); 
            gsub(/^ +| +$/, "", s); 
            print s 
        }') 
        echo "Processing $CMD ID $ID (status: $STATUS)" 

        # Shutdown logic 
        if [[ "$STATUS" == "running" ]]; then 
            if ! $CMD shutdown --timeout 60 "$ID"; then 
                echo "Force stopping $ID" 
                $CMD stop "$ID" 
            fi 
        fi 

        # Rollback logic 
        success=false 
        targets=(base) 

        for target in "${targets[@]}"; do 
                echo "Trying rollback to $target..." 

                if $CMD rollback "$ID" "$target"; then 
                        echo "Rollback to $target succeeded!" 
                        success=true 
                        break 
                fi 
        done 

        if [ "$success" = false ]; then 
                echo "All rollback attempts failed" 
        fi 

        echo 
    done 
} 

DEFAULT_ARGUMENTS=(ubu ubudesk) 

# set default if no args 
if [ "$#" -eq 0 ]; then 

        set -- "${DEFAULT_ARGUMENTS[@]}" 

fi 

# VNODES refers to the hostname of a remote VNODE to ssh into. 
VNODES=(vnode2 vnode3 vnode4) 
PROXMOX_USER=root 

for arg in "$@"; do 
        printf "\nRunning on vnode1 for $arg...\n" 
        reset_guests "$arg" pct 
        reset_guests "$arg" qm 

        for VNODE in "${VNODES[@]}"; do 
                printf "\nAttempting to run on $VNODE for $arg...\n" 
                ssh "${user:-root}"@"$VNODE" /usr/local/bin/proxmox-restore.sh $arg 
        done 
done 

