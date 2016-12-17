# Prepare the Devstack config files for the controller and the node
# and copy them to the devstack directory

# ===============
# Controller Node
# ===============

# Install dependencies
apt-get update
apt-get install -qqy git

# Create the "stack" user used to install devstack
controller_ip=$( ip addr show ens3 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1 )
git clone https://github.com/openstack-dev/devstack.git /root/devstack
export HOST_IP=$controller_ip
/root/devstack/tools/create-stack-user.sh

# Configure devstack for the controller node
cp ~/devstack-lxc/controller-local.conf /root/devstack/local.conf
sed -ir "s|{ host_ip }|$controller_ip|g" /root/devstack/local.conf
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
~/devstack-lxc/setup-container.sh


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
cp ~/devstack-lxc/compute-local.conf /var/lib/lxc/devstack-node/rootfs/root/devstack/local.conf
sed -ir "s|{ service_host }|$controller_ip|g" /var/lib/lxc/devstack-node/rootfs/root/devstack/local.conf
sed -ir "s|{ host_ip }|$node_ip|g" /var/lib/lxc/devstack-node/rootfs/root/devstack/local.conf
# This line below is to remove a line in devstack/functions so devstack
# does not fail when installing in a container
# TODO (Cas): If the host does not need this lane changed we can change it
# here before copying it
sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-${proto}tables=1/echo "Skipping. This breaks when run in a LXC container."/g' /var/lib/lxc/devstack-node/rootfs/root/devstack/functions

# Copy the devstack directory to opt/stack
lxc-attach -n devstack-node -- bash -c "cp -r /root/devstack /opt/stack"
lxc-attach -n devstack-node -- bash -c "sudo chown -R stack:stack  /opt/stack/devstack"

# Run the script to install devstack
lxc-attach -n devstack-node -- bash -c "cd /opt/stack/devstack; sudo -u stack -H sh -c 'export HOST_IP=$controller_ip; ./stack.sh' "

