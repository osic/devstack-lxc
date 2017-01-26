# Installs an all in one devstack in an LXC container.

# ===================
# All In One Devstack
# ===================

# Install dependencies
apt-get update
apt-get install -qqy git


# ========================
# Create the lxc container
# ========================
~/devstack-lxc/setup-containers.sh devstack-node


# ===================
# All In One Devstack
# ===================

# Install dependencies
lxc-attach -n devstack-node -- bash -c "apt-get update; apt-get install -qqy bsdmainutils git ca-certificates"

# Create the "stack" user to use for installing devstack
node_inet=$( lxc-attach -n devstack-node -- bash -c "ip addr show eth0 | grep 'inet\b'" )
node_ip=$( echo $node_inet | awk '{print $2}' | cut -d/ -f1 )
lxc-attach -n devstack-node -- bash -c "git clone https://github.com/openstack-dev/devstack.git /root/devstack"
lxc-attach -n devstack-node -- bash -c "export HOST_IP=$node_ip; /root/devstack/tools/create-stack-user.sh"

# Configure devstack for an all in one
cp ~/devstack-lxc/aio-local.conf /var/lib/lxc/devstack-node/rootfs/root/devstack/local.conf
sed -ir "s|{ host_ip }|$node_ip|g" /var/lib/lxc/devstack-node/rootfs/root/devstack/local.conf
# This line below is to remove a line in devstack/functions so devstack
# does not fail when installing in a container
sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-${proto}tables=1/echo "Skipping. This breaks when run in a LXC container."/g' /var/lib/lxc/devstack-node/rootfs/root/devstack/functions

# Copy the devstack directory to opt/stack
lxc-attach -n devstack-node -- bash -c "cp -r /root/devstack /opt/stack"
lxc-attach -n devstack-node -- bash -c "sudo chown -R stack:stack  /opt/stack/devstack"

# Run the script to install devstack
lxc-attach -n devstack-node -- bash -c "cd /opt/stack/devstack; sudo -u stack -H sh -c 'export HOST_IP=$node_ip; ./stack.sh' "

