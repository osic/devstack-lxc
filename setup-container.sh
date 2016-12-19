# Install dependencies
apt-get install -qqy lxc lxctl lxc-templates qemu debootstrap

# Create and start the container
echo "Creating the lxc container ..."
lxc-create -t ubuntu -n devstack-node -f ~/devstack-lxc/node-container.conf
echo "Starting the lxc container  ..."
lxc-start --name devstack-node && \
echo "The lxc container devstack-node is active." || \
echo "The lxc container devstack-node failed to be started."
# Wait up to 5 minutes for the container to be running
lxc-wait -n devstack-node -s RUNNING -t 300
# Adding a sleep time to allow for the network interfaces to go up
sleep 5
