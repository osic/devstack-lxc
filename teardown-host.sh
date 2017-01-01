# Cleans up devstack in the host
DIR=/opt/stack/devstack
if [ -d "$DIR" ]; then
    $DIR/unstack.sh
    $DIR/cleanup.sh
    echo '%s\n' "Removing ($DIR)"
    rm -rf "$DIR"
    echo '%s\n' "Removing $HOME/devstack"
    rm -rf ~/devstack 
fi

