#!/bin/bash

# Check if "gaianet" directory exists in $HOME
if [ ! -d "$HOME/gaianet" ]; then
    printf "Not found $HOME/gaianet\n"
    exit 1
fi
# Set "gaianet_base_dir" to $HOME/gaianet
gaianet_base_dir="$HOME/gaianet"

# stop the Qdrant instance
qdrant_pid=$gaianet_base_dir/qdrant.pid
if [ -f $qdrant_pid ]; then
    printf "[+] Stopping Qdrant instance ...\n"
    kill -9 $(cat $qdrant_pid)
    rm $qdrant_pid
fi

# stop the api-server
llamaedge_pid=$gaianet_base_dir/llamaedge.pid
if [ -f $llamaedge_pid ]; then
    printf "[+] Stopping API server ...\n"
    kill -9 $(cat $llamaedge_pid)
    rm $llamaedge_pid
fi

# stop gaianet-domain
gaianet_domain_pid=$gaianet_base_dir/gaianet-domain.pid
if [ -f $gaianet_domain_pid ]; then
    printf "[+] Stopping gaianet-domain ...\n"
    kill -9 $(cat $gaianet_domain_pid)
    rm $gaianet_domain_pid
fi
