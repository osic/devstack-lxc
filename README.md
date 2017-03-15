# devstack-lxc
# Cas: Temp comment

Shell scripts to deploy different types of Devstack environments using LXC containers.

# Steps to Use
- Change to the root user: sudo su -
- Clone this repository: git clone https://github.com/osic/devstack-lxc.git
- Run one of these scripts depending on what kind of environment you want:
     - aio-lxc.sh: Installs Devstack in an LXC container.
     - multinode-vm-lxc.sh: Installs a multi-node Devstack, the controller node in the host and a compute node in an LXC container.  
     - multinode-lxc.sh: Installs a multi-node Devstack in LXC containers.
     - grenade-multinode.sh: Installs a multi-node Devstack with Grenade so we can run upgrade tests in multi-node. 
- To stop and destroy the containers, run teardown.sh

Note: When referring to multi-node environment we meant 2 nodes.
Note: We won't be persuing this POC anymore, it has limitations when using Swift and Cinder.
