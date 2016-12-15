# Install dependencies
apt-get update
apt-get install -qqy bsdmainutils git ca-certificates

# Prepare the devstack source files 
git clone https://github.com/openstack-dev/devstack.git
sed -i -e 's/sudo sysctl -w net.bridge.bridge-nf-call-${proto}tables=1/echo "Skipping. This breaks when run in a LXC container."/g' devstack/functions
export HOST_IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
devstack/tools/create-stack-user.sh
su stack
cd /opt/stack
git clone https://github.com/openstack-dev/devstack.git
