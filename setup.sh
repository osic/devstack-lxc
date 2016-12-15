# Install dependencies
apt-get install -qqy lxc lxctl lxc-templates qemu debootstrap

# Change permission on files to make them executable
chmod +755 bootstrap-devstack.sh
chmod +755 pre-start.sh
chmod +755 prep-guest.sh
chmod +755 run-devstack.sh
chmod +755 teardown.sh

# Create and start the container
echo "Creating the lxc container ..."
lxc-create -t ubuntu -n devstack-node -f devstack-node.conf
echo "Starting the lxc container for the first time ..."
lxc-start --name devstack-node
echo "The lxc container devstack-node has been created and is active."
