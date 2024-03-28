# !/bin/bash

# stop the Qdrant instance
if [ -f "qdrant.pid" ]; then
    printf "[+] Stopping Qdrant instance ...\n"
    kill $(cat qdrant.pid)
    rm qdrant.pid
fi

# stop the api-server
if [ -f "llamaedge.pid" ]; then
    printf "[+] Stopping API server ...\n"
    kill $(cat llamaedge.pid)
    rm llamaedge.pid
fi

# stop gaianet-domain
if [ -f "gaianet-domain.pid" ]; then
    printf "[+] Stopping gaianet-domain ...\n"
    kill $(cat gaianet-domain.pid)
    rm gaianet-domain.pid
fi