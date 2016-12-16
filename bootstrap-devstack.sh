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

# Prepare the devstack source files for the compute node
cp prep-guest.sh /var/lib/lxc/devstack-node/rootfs/root
lxc-attach -n devstack-node -- bash -c "echo /root/prep-guest.sh | sh"
node_inet=$( lxc-attach -n devstack-node -- bash -c "echo \"ip addr show eth0 | grep 'inet\b' \" | sh " )
node_ip=$( echo $node_inet | awk '{print $2}' | cut -d/ -f1 )
sed -ir "s|{ service_host }|$controller_ip|g" ~/devstack-lxc/compute-node.conf
sed -ir "s|{ host_ip }|$node_ip|g" ~/devstack-lxc/compute-node.conf
cp compute-node.conf /var/lib/lxc/devstack-node/rootfs/opt/stack/devstack/local.conf

# Run the script to install devstack
cp run-devstack.sh /var/lib/lxc/devstack-node/rootfs/opt/stack
lxc-attach -n devstack-node -- bash -c "echo sudo -H -u stack /opt/stack/run-devstack.sh | sh"
