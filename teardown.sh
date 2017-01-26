# Stop and delete the lxc containers listed in containers.txt
while read container
do
    lxc-stop --name $container
    lxc-destroy --name $container
    echo "The lxc container $container has been deleted."
done <containers.txt
# Delete the containers.txt file
rm ./containers.txt
