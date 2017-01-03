# Install dependencies
apt-get install -qqy lxc lxctl lxc-templates qemu debootstrap

# Create and start the containers
echo "Creating the lxc containers ..."
for container in "controller-node" "compute-node"
do

    lxc-create -t ubuntu -n $container -f ~/devstack-lxc/container.conf
    echo "Starting the lxc container  ..."
    lxc-start --name $container && \
    echo "The lxc container $container is active." || \
    echo "The lxc container $container failed to be started."
    # Wait up to 5 minutes for the container to be running
    lxc-wait -n $container -s RUNNING -t 300    
	
done

# Adding a sleep time to allow for the network interfaces to go up
sleep 5
