# Stop and delete the lxc container
lxc-stop --name devstack-node
lxc-destroy --name devstack-node
echo "The lxc container devstack-node has been deleted."
