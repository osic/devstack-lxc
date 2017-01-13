# devstack-lxc
Shell scripts to deploy a multi-node Devstack environment with both nodes in LXCs containers within the host.
The controller node is deployed with Grenade so we can run upgrade tests in the multi-node environment.

# Steps to Use
- Change to the root user: sudo su -
- Clone this repository
- Run install-multinode.sh
- You can alternatively run install-aio.sh to install an all in one insidde the LXC container

To stop and destroy the containers, run teardown.sh
