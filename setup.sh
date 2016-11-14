chmod +755 bootstrap-devstack.sh
chmod +755 pre-start.sh
chmod +755 prep-guest.sh
chmod +755 run-devstack.sh
chmod +755 teardown.sh

lxc-create -t ubuntu -n devstack -f devstack.conf
lxc-start --name devstack