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
lxc-attach -n controller-node -- bash -c "apt-get update; apt-get install -qqy bsdmainutils git ca-certificates python-pip vim build-essential libssl-dev libffi-dev python-dev libxml2-dev libxslt1-dev libpq-dev python3-pip"

# Create the "stack" user to use for installing devstack
controller_inet=$( lxc-attach -n controller-node -- bash -c "ip addr show eth0 | grep 'inet\b'" )
controller_ip=$( echo $controller_inet | awk '{print $2}' | cut -d/ -f1 )
lxc-attach -n controller-node -- bash -c "git clone https://github.com/openstack-dev/devstack.git /root/devstack"
lxc-attach -n controller-node -- bash -c "export HOST_IP=$controller_ip; /root/devstack/tools/create-stack-user.sh"

# Clone Grenade
lxc-attach -n controller-node -- bash -c "git clone https://github.com/openstack-dev/grenade.git /root/grenade"

# Configure grenade/devstack for a controller node
cp ~/devstack-lxc/devstack.localrc /var/lib/lxc/controller-node/rootfs/root/grenade/devstack.localrc
sed -ir "s|{ host_ip }|$controller_ip|g" /var/lib/lxc/controller-node/rootfs/root/grenade/devstack.localrc

# This line below is to remove a line in devstack/functions so devstack
# does not fail when installing in a container
devstack_fix="\        sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-\${proto}tables=1/echo \"Skipping. This breaks when run in a LXC container.\"/g' \$BASE_DEVSTACK_DIR/functions"
sed -i "/git_clone \$BASE_DEVSTACK_REPO \$BASE_DEVSTACK_DIR \$BASE_DEVSTACK_BRANCH/a $devstack_fix" /var/lib/lxc/controller-node/rootfs/root/grenade/inc/bootstrap

# Do not shut down the OpenStack services or the compute node
# will fail to install. Overwrite grenade.sh script
sed -i '/echo_summary "Shutting down all services on base devstack..."/i #echo_summary "NOTE: Overwriting the Grenade script to not stop the OpenStack services so we can install the compute node."' /var/lib/lxc/controller-node/rootfs/root/grenade/grenade.sh
sed -i 's/echo_summary "Shutting down all services on base devstack..."/#echo_summary "Shutting down all services on base devstack..."/g' /var/lib/lxc/controller-node/rootfs/root/grenade/grenade.sh
sed -i 's/shutdown_services/#shutdown_services/g' /var/lib/lxc/controller-node/rootfs/root/grenade/grenade.sh
sed -i 's/resources verify_noapi pre-upgrade/#resources verify_noapi pre-upgrade/g' /var/lib/lxc/controller-node/rootfs/root/grenade/grenade.sh

# Move the services shutdown and pre-upgrade resources verification to the
# begining of the Upgrade stage of the script
shutdown_services="\    echo_summary \"NOTE: Overwriting the Grenade script to shutdown the OpenStack services as first step of te upgrade.\"\n    echo_summary \"Shutting down all services on base devstack...\"\n    shutdown_services\n    resources verify_noapi pre-upgrade\n" 
sed -i "/if \[\[ \"\$RUN_TARGET\" == \"True\" \]\]; then/a $shutdown_services" /var/lib/lxc/controller-node/rootfs/root/grenade/grenade.sh 

# Temporary fix for Grenade until bug 1659081 is resolved
sed -i '/source $TARGET_DEVSTACK_DIR\/inc\/python/i source $TARGET_DEVSTACK_DIR/functions-common' /var/lib/lxc/controller-node/rootfs/root/grenade/inc/bootstrap

# Copy the devstack directory to opt/stack
lxc-attach -n controller-node -- bash -c "cp -r /root/grenade /opt/stack"
lxc-attach -n controller-node -- bash -c "sudo chown -R stack:stack  /opt/stack/grenade"

# Run the script to install devstack
lxc-attach -n controller-node -- bash -c "cd /opt/stack/grenade; sudo -u stack -H sh -c './grenade.sh -b' "


# ===============
# Compute Node
# ===============

lxc-attach -n compute-node -- bash -c "apt-get update; apt-get install -qqy bsdmainutils git ca-certificates python-pip vim build-essential libssl-dev libffi-dev python-dev libxml2-dev libxslt1-dev libpq-dev python3-pip"

# Create the "stack" user to use for installing devstack. 
# Note: Get a devstack release that matches the base grenade devstack.
compute_inet=$( lxc-attach -n compute-node -- bash -c "ip addr show eth0 | grep 'inet\b'" )
compute_ip=$( echo $compute_inet | awk '{print $2}' | cut -d/ -f1 )
lxc-attach -n compute-node -- bash -c "git clone -b stable/newton https://github.com/openstack-dev/devstack.git /root/devstack"
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


# ===============
# Run The Upgrade
# ===============

lxc-attach -n controller-node -- bash -c "apt-get install -qqy python3-pip"
lxc-attach -n controller-node -- bash -c "cd /opt/stack/grenade; sudo -u stack -H sh -c './grenade.sh -t' "
