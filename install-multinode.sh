# Prepare the Devstack config files for the controller and Compute nodes
# and copy them to the devstack directory


# =========================
# Create the lxc containers
# =========================
~/devstack-lxc/setup-containers.sh


# ===============
# Controller Node
# ===============

# Install dependencies
lxc-attach -n controller-node -- bash -c "apt-get update; apt-get install -qqy bsdmainutils git ca-certificates"

# Create the "stack" user to use for installing devstack
controller_inet=$( lxc-attach -n controller-node -- bash -c "ip addr show eth0 | grep 'inet\b'" )
controller_ip=$( echo $controller_inet | awk '{print $2}' | cut -d/ -f1 )
lxc-attach -n controller-node -- bash -c "git clone https://github.com/openstack-dev/devstack.git /root/devstack"
lxc-attach -n controller-node -- bash -c "export HOST_IP=$controller_ip; /root/devstack/tools/create-stack-user.sh"

# Configure devstack for a controller node
cp ~/devstack-lxc/controller-local.conf /var/lib/lxc/controller-node/rootfs/root/devstack/local.conf
sed -ir "s|{ host_ip }|$controller_ip|g" /var/lib/lxc/controller-node/rootfs/root/devstack/local.conf
# This line below is to remove a line in devstack/functions so devstack
# does not fail when installing in a container
sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-${proto}tables=1/echo "Skipping. This breaks when run in a LXC container."/g' /var/lib/lxc/controller-node/rootfs/root/devstack/functions

# Copy the devstack directory to opt/stack
lxc-attach -n controller-node -- bash -c "cp -r /root/devstack /opt/stack"
lxc-attach -n controller-node -- bash -c "sudo chown -R stack:stack  /opt/stack/devstack"

# Run the script to install devstack
lxc-attach -n controller-node -- bash -c "cd /opt/stack/devstack; sudo -u stack -H sh -c 'export HOST_IP=$controller_ip; ./stack.sh' "


# ===============
# Compute Node
# ===============

# Install dependencies
lxc-attach -n compute-node -- bash -c "apt-get update; apt-get install -qqy bsdmainutils git ca-certificates"

# Create the "stack" user to use for installing devstack
compute_inet=$( lxc-attach -n compute-node -- bash -c "ip addr show eth0 | grep 'inet\b'" )
compute_ip=$( echo $compute_inet | awk '{print $2}' | cut -d/ -f1 )
lxc-attach -n compute-node -- bash -c "git clone https://github.com/openstack-dev/devstack.git /root/devstack"
lxc-attach -n compute-node -- bash -c "export HOST_IP=$compute_ip; /root/devstack/tools/create-stack-user.sh"

# Configure devstack for a compute node
cp ~/devstack-lxc/compute-local.conf /var/lib/lxc/compute-node/rootfs/root/devstack/local.conf
sed -ir "s|{ service_host }|$controller_ip|g" /var/lib/lxc/compute-node/rootfs/root/devstack/local.conf
sed -ir "s|{ host_ip }|$compute_ip|g" /var/lib/lxc/compute-node/rootfs/root/devstack/local.conf
# This line below is to remove a line in devstack/functions so devstack
# does not fail when installing in a container
sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-${proto}tables=1/echo "Skipping. This breaks when run in a LXC container."/g' /var/lib/lxc/compute-node/rootfs/root/devstack/functions

# Copy the devstack directory to opt/stack
lxc-attach -n compute-node -- bash -c "cp -r /root/devstack /opt/stack"
lxc-attach -n compute-node -- bash -c "sudo chown -R stack:stack  /opt/stack/devstack"

# Run the script to install devstack
lxc-attach -n compute-node -- bash -c "cd /opt/stack/devstack; sudo -u stack -H sh -c 'export HOST_IP=$compute_ip; ./stack.sh' "

