# Stop and delete the lxc containers
for container in "controller-node" "compute-node"
do
    lxc-stop --name $container
    lxc-destroy --name $container
    echo "The lxc container $container has been deleted."
done
