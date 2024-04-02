#!/bin/bash


snapshot=""
embedding_url=""
model_url=""

function print_usage {
    printf "Usage:\n"
    printf "  ./config.sh\n\n"
    printf "  --snapshot: Url or local path of Qdrant collection snapshot\n"
    printf "  --embedding: Url of GGUF embedding model\n"
    printf "  --chat: Url of GGUF chat model\n"
    printf "  --help: Print usage\n"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --snapshot)
            snapshot="$2"
            shift
            shift
            ;;
        --embedding)
            embedding_url="$2"
            shift
            shift
            ;;
        --chat)
            model_url="$2"
            shift
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

printf "\n"

# Check if "gaianet" directory exists in $HOME
if [ ! -d "$HOME/gaianet" ]; then
    printf "[+] Creating gaianet directory in $HOME ...\n\n"
    # If not, create it
    mkdir -p $HOME/gaianet
fi
# Set "base_dir" to $HOME/gaianet
gaianet_base_dir="$HOME/gaianet"

cd $gaianet_base_dir
# check if config.json exists or not
if [ ! -f "$gaianet_base_dir/config.json" ]; then
    printf "[+] Downloading config.json ...\n\n"
    curl -s -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/demo/config.json
fi

if [ -z "$model_url" ]; then
    model_url=$(awk -F'"' '/"chat":/ {print $4}' config.json)
    printf "[+] Using the cached chat model: $model_url\n\n"

else
    # printf "Please specify a chat url using '--chat-url' option\n"
    sed -i.bak "s|\(\"chat\":\s*\).*|\1\"$model_url\",|" config.json
    printf "[+] Using the provided chat model: $model_url\n\n"
fi

if [ -z "$embedding_url" ]; then
    embedding_url=$(awk -F'"' '/"embedding":/ {print $4}' config.json)
    printf "[+] Using the cached embedding model: $embedding_url\n\n"
else
    sed -i.bak "s|\(\"embedding\":\s*\).*|\1\"$embedding_url\",|" config.json
    printf "[+] Using the provided embedding model: $embedding_url\n\n"
fi

if [ -z "$snapshot" ]; then
    snapshot=$(awk -F'"' '/"snapshot":/ {print $4}' config.json)
    printf "[+] Using the cached Qdrant collection snapshot: $snapshot\n\n"
else
    sed -i.bak "s|\(\"snapshot\":\s*\).*|\1\"$snapshot\"|" config.json
    printf "[+] Using the provided Qdrant collection snapshot: $snapshot\n\n"
fi

rm -f config.json.bak

exit 0
