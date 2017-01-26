# Prepare the Devstack config files for the controller and the node
# and copy them to the devstack directory


# ========================
# Create the lxc container
# ========================
~/devstack-lxc/setup-containers.sh devstack-node


# ===============
# Controller Node
# ===============

# Install dependencies
lxc-attach -n devstack-node -- bash -c "apt-get update; apt-get install -qqy bsdmainutils git ca-certificates"

# Create the "stack" user to use for installing devstack
container_inet=$( lxc-attach -n devstack-node -- bash -c "ip addr show eth0 | grep 'inet\b'" )
container_ip=$( echo $container_inet | awk '{print $2}' | cut -d/ -f1 )
lxc-attach -n devstack-node -- bash -c "git clone https://github.com/openstack-dev/devstack.git /root/devstack"
lxc-attach -n devstack-node -- bash -c "export HOST_IP=$container_ip; /root/devstack/tools/create-stack-user.sh"

# Configure devstack for a controller node
cp ~/devstack-lxc/controller-local.conf /var/lib/lxc/devstack-node/rootfs/root/devstack/local.conf
sed -ir "s|{ host_ip }|$container_ip|g" /var/lib/lxc/devstack-node/rootfs/root/devstack/local.conf
# This line below is to remove a line in devstack/functions so devstack
# does not fail when installing in a container
sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-${proto}tables=1/echo "Skipping. This breaks when run in a LXC container."/g' /var/lib/lxc/devstack-node/rootfs/root/devstack/functions

# Copy the devstack directory to opt/stack
lxc-attach -n devstack-node -- bash -c "cp -r /root/devstack /opt/stack"
lxc-attach -n devstack-node -- bash -c "sudo chown -R stack:stack  /opt/stack/devstack"

# Run the script to install devstack
lxc-attach -n devstack-node -- bash -c "cd /opt/stack/devstack; sudo -u stack -H sh -c 'export HOST_IP=$container_ip; ./stack.sh' "


# ===============
# Compute Node
# ===============

# Install dependencies
apt-get update
apt-get install -qqy git

# Create the "stack" user used to install devstack
vm_ip=$( ip addr show ens3 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1 )
git clone https://github.com/openstack-dev/devstack.git /root/devstack
export HOST_IP=$vm_ip
/root/devstack/tools/create-stack-user.sh

# Configure devstack for the compute node
cp ~/devstack-lxc/compute-local.conf /root/devstack/local.conf
sed -ir "s|{ host_ip }|$vm_ip|g" /root/devstack/local.conf
sed -ir "s|{ service_host }|$container_ip|g" /root/devstack/local.conf

# Copy the devstack directory to opt/stack
cp -r /root/devstack /opt/stack
sudo chown -R stack:stack  /opt/stack/devstack

# Run the script to install devstack
cd /opt/stack/devstack
sudo -u stack -H sh -c "export HOST_IP=$vm_ip; ./stack.sh"
