# Install dependencies
apt-get install -qqy lxc lxctl lxc-templates qemu debootstrap

# Create and start the container
echo "Creating the lxc container ..."
lxc-create -t ubuntu -n devstack-node -f ~/devstack-lxc/node-container.conf
echo "Starting the lxc container  ..."
lxc-start --name devstack-node && \
echo "The lxc container devstack-node is active." || \
echo "The lxc container devstack-node failed to be started."

# Add some sleep time to allow for the interfaces to finish going up
sleep 5 
