# devstack-lxc

Shell scripts to deploy different types of Devstack environments using LXC containers.

# Steps to Use
- Change to the root user: sudo su -
- Clone this repository
- Run one of these scripts depending on what kind of environment you want:
     - aio-lxc.sh: Installs Devstack in an LXC container. 
     - multinode-lxc.sh: Installs a multi-node Devstack (2 nodes) in LXC containers.
     - grenade-multinode.sh: Installs a multi-node Devstack (2 nodes) with Grenade so we can run upgrade tests in multi-node. 

To stop and destroy the containers, run teardown.sh
