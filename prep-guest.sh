# Install dependencies
apt-get update
apt-get install -qqy bsdmainutils git ca-certificates

# Prepare the devstack source files 
git clone https://github.com/openstack-dev/devstack.git /root/devstack
sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-${proto}tables=1/echo "Skipping. This breaks when run in a LXC container."/g' /root/devstack/functions
export HOST_IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
/root/devstack/tools/create-stack-user.sh
echo "User stack created successfully."
su stack
cp -r /root/devstack /opt/stack

