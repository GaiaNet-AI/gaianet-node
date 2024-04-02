#!/bin/bash

# 1: stop WasmEdge, Qdrant and frpc processes
force_stop=0

function print_usage {
    printf "Usage:\n"
    printf "  ./stop.sh [--force-stop]\n\n"
    printf "  --force:  stop WasmEdge, Qdrant and frpc processes\n"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --force)
            force_stop=1
            shift
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $key"
            print_usage
            exit 1
            ;;
    esac
done

# Check if "gaianet" directory exists in $HOME
if [ ! -d "$HOME/gaianet" ]; then
    printf "Not found $HOME/gaianet\n"
    exit 1
fi
# Set "gaianet_base_dir" to $HOME/gaianet
gaianet_base_dir="$HOME/gaianet"

if [ $force_stop -eq 1 ]; then
    printf "Force stopping WasmEdge, Qdrant and frpc processes ...\n"
    pkill -9 wasmedge
    pkill -9 qdrant
    pkill -9 frpc

    qdrant_pid=$gaianet_base_dir/qdrant.pid
    if [ -f $qdrant_pid ]; then
        rm $qdrant_pid
    fi

    llamaedge_pid=$gaianet_base_dir/llamaedge.pid
    if [ -f $llamaedge_pid ]; then
        rm $llamaedge_pid
    fi

    gaianet_domain_pid=$gaianet_base_dir/gaianet-domain.pid
    if [ -f $gaianet_domain_pid ]; then
        rm $gaianet_domain_pid
    fi

else

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
fi

exit 0