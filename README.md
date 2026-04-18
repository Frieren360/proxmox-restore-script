# proxmox-restore-script
This script automatically rollbacks proxmox containers and virtual machines to user-defined snapshots. It utilizes basic Unix utilities such as grep, awk, and tail to form the list of VMIDs for both containers and QEMU virtual machines. Then it recursively performs either the `qm` or `pct` command to shutdown then perform the restore.

## Setup

Each remote node is expected to have a file in /usr/local/bin/proxmox-restore.sh without the ssh logic (this is the proxmox-remote-restore.sh file). This is so that the master vnode that the main script is being run from, can remotely run the script on each node without entering a massive loop.

## Examples

`proxmox-restore.sh`
`proxmox-restore.sh ubu ubudesk`

## Configuration

Currently, the script only accepts positional arguments containing search terms of each Proxmox container and virtual machine. It expects a number at the end of each VM/LXC container and recursively loops through each, depending on the search term being used.

Inside the script you can also edit arrays such as the search term to be used with the `DEFAULT_ARGUMENTS` array and the snapshots to use when rolling back with the target array.


## The Main Function

`reset_guests [search terms] pct/qm`

If only the logic to reset guests is required, copying the reset_guests bash function then running it can be sufficient.

EXAMPLE: `reset_guests cyberlab pct`

Search terms refer to the LXC container or QEMU virtual machine to search for in Proxmox.

`pct` refers to the main command to use for LXC containers.

`qm` refers to the main command to use for QEMU VM containers.
