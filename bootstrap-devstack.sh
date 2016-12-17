# Prepare the Devstack config files for the controller and the node
# and copy them to the devstack directory

# ===============
# Controller Node
# ===============

# Install dependencies
apt-get update
apt-get install -qqy git

# Create the "stack" user to use for installing devstack
controller_ip=$( ip addr show ens3 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1 )
git clone https://github.com/openstack-dev/devstack.git /root/devstack
export HOST_IP=$controller_ip
/root/devstack/tools/create-stack-user.sh

# Configure devstack for a controller node
sed -ir "s|{ host_ip }|$controller_ip|g" ~/devstack-lxc/local.conf
cp ~/devstack-lxc/local.conf /root/devstack/local.conf
# TODO (Cas): This line is needed in the lxc container for devstack to work.
# It is yet to be discovered if it is needed in the host VM.
#sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-${proto}tables=1/echo "Skipping. This breaks when run in a LXC container."/g' /root/devstack/functions

# Copy the devstack directory to opt/stack
cp -r /root/devstack /opt/stack
sudo chown -R stack:stack  /opt/stack/devstack

# Run the script to install devstack
cd /opt/stack/devstack
sudo -u stack -H sh -c "export HOST_IP=$controller_ip; ./stack.sh"


# ========================
# Create the lxc container
# ========================
~/devstack-lxc/setup.sh


# ===============
# Compute Node
# ===============

# Install dependencies
lxc-attach -n devstack-node -- bash -c "apt-get update; apt-get install -qqy bsdmainutils git ca-certificates"

# Create the "stack" user to use for installing devstack
node_inet=$( lxc-attach -n devstack-node -- bash -c "ip addr show eth0 | grep 'inet\b'" )
node_ip=$( echo $node_inet | awk '{print $2}' | cut -d/ -f1 )
lxc-attach -n devstack-node -- bash -c "git clone https://github.com/openstack-dev/devstack.git /root/devstack"
lxc-attach -n devstack-node -- bash -c "export HOST_IP=$node_ip; /root/devstack/tools/create-stack-user.sh"

# Configure devstack for a compute node
sed -ir "s|{ service_host }|$controller_ip|g" ~/devstack-lxc/compute-node.conf
sed -ir "s|{ host_ip }|$node_ip|g" ~/devstack-lxc/compute-node.conf
cp ~/devstack-lxc/compute-node.conf /var/lib/lxc/devstack-node/rootfs/root/devstack/local.conf
# This line needs to be removed so devstack does not fail in a container
# TODO (Cas): If the host does not need this lane changed we can change it
# here before copying it
sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-${proto}tables=1/echo "Skipping. This breaks when run in a LXC container."/g' /root/devstack/functions
rm /var/lib/lxc/devstack-node/rootfs/root/devstack/functions
cp /root/devstack/functions /var/lib/lxc/devstack-node/rootfs/root/devstack

# Copy the devstack directory to opt/stack
lxc-attach -n devstack-node -- bash -c "cp -r /root/devstack /opt/stack"
lxc-attach -n devstack-node -- bash -c "sudo chown -R stack:stack  /opt/stack/devstack"

# Run the script to install devstack
lxc-attach -n devstack-node -- bash -c "cd /opt/stack/devstack; sudo -u stack -H sh -c 'export HOST_IP=$controller_ip; ./stack.sh' "

