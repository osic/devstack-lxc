apt-get update
apt-get install -qqy bsdmainutils git ca-certificates
git clone https://github.com/dwalleck/devstack
devstack/tools/create-stack-user.sh
su stack
cd /opt/stack
git clone https://github.com/dwalleck/devstack