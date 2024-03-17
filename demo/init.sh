# !/bin/bash

# target name
target=$(uname -m)


# check if config.json exists or not
if [ ! -f "config.json" ]; then
    printf "config.json file not found\n"
    exit 1
fi
# represents the directory where the script is located
cwd=$(pwd)

printf "\n"

# 1. Check if "gaianet" directory exists in $HOME
if [ ! -d "$HOME/gaianet" ]; then
    # If not, create it
    mkdir -p $HOME/gaianet
fi
# Set "base_dir" to $HOME/gaianet
base_dir="$HOME/gaianet"

# 2. Install WasmEdge with wasi-nn_ggml plugin for local user
printf "[+] Installing WasmEdge with wasi-nn_ggml plugin ...\n\n"
if curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- --plugins wasi_nn-ggml wasmedge_rustls; then
    source $HOME/.wasmedge/env
    wasmedge_path=$(which wasmedge)
    wasmedge_version=$(wasmedge --version)
    printf "\n    The WasmEdge Runtime %s is installed in %s.\n\n" "$wasmedge_version" "$wasmedge_path"
else
    echo "Failed to install WasmEdge"
    exit 1
fi
printf "\n"

# 3. Install Qdrant at $HOME/gaianet/bin
printf "[+] Installing Qdrant...\n\n"
# Check if "$base_dir/bin" directory exists
if [ ! -d "$base_dir/bin" ]; then
    # If not, create it
    mkdir -p $base_dir/bin
fi
qdrant_version="v1.8.1"
if [ "$(uname)" == "Darwin" ]; then
    # download qdrant binary
    if [ "$target" = "x86_64" ]; then
        curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-apple-darwin.tar.gz
        tar -xzf qdrant-x86_64-apple-darwin.tar.gz -C $base_dir/bin
        rm qdrant-x86_64-apple-darwin.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-apple-darwin.tar.gz
        tar -xzf qdrant-aarch64-apple-darwin.tar.gz -C $base_dir/bin
        rm qdrant-aarch64-apple-darwin.tar.gz
    fi
    echo 'export PATH=$PATH:'$base_dir'/bin' >> $HOME/.bashrc

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # download qdrant statically linked binary
    if [ "$target" = "x86_64" ]; then
        curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-unknown-linux-musl.tar.gz
        tar -xzf qdrant-x86_64-unknown-linux-musl.tar.gz -C $base_dir/bin
        rm qdrant-x86_64-unknown-linux-musl.tar.gz
    elif [ "$target" = "aarch64" ]; then
        curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-unknown-linux-musl.tar.gz
        tar -xzf qdrant-aarch64-unknown-linux-musl.tar.gz -C $base_dir/bin
        rm qdrant-aarch64-unknown-linux-musl.tar.gz
    fi
    echo 'export PATH=$PATH:'$base_dir'/bin' >> $HOME/.bashrc

elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    printf "For Windows users, please run this script in WSL.\n"
    exit 1
else
    printf "Only support Linux, MacOS and Windows.\n"
    exit 1
fi
printf "\n"


# 4. Download GGUF chat model to $HOME/gaianet
url_chat_model=$(awk -F'"' '/"chat":/ {print $4}' config.json)
if [[ $url_chat_model =~ ^https://huggingface\.co/second-state ]]; then
    chat_model=$(basename $url_chat_model)

    if [ -f "$base_dir/$chat_model" ]; then
        printf "[+] Using the cached chat model: $chat_model\n"
    else
        printf "[+] Downloading $chat_model ...\n\n"
        curl -L $url_chat_model -o $base_dir/$chat_model
    fi
    printf "\n"
else
    printf "Error: the chat model is not from https://huggingface.co/second-state\n"
    exit 1
fi

# 5. Download GGUF embedding model to $HOME/gaianet
url_embedding_model=$(awk -F'"' '/"embedding":/ {print $4}' config.json)
if [[ $url_embedding_model =~ ^https://huggingface\.co/second-state ]]; then
    embedding_model=$(basename $url_embedding_model)

    if [ -f "$base_dir/$embedding_model" ]; then
        printf "[+] Using the cached embedding model: $embedding_model\n"
    else
        printf "[+] Downloading $embedding_model ...\n\n"
        curl -L $url_embedding_model -o $base_dir/$embedding_model
    fi
    printf "\n"
else
    printf "Error: the embedding model is not from https://huggingface.co/second-state\n"
    exit 1
fi

# 6. Download llama-api-server.wasm
printf "[+] Downloading the llama-api-server.wasm ...\n\n"
cd $base_dir
curl -LO https://github.com/LlamaEdge/LlamaEdge/raw/feat-server-multi-models/api-server/llama-api-server.wasm
printf "\n"

# 7. Download dashboard to $HOME/gaianet
if [ -d "$base_dir/dashboard" ]; then
    printf "[+] Using cached dashboard ...\n"
else
    printf "[+] Downloading dashboard ...\n"
    if [ -d "$base_dir/gaianet-node" ]; then
        rm -rf $base_dir/gaianet-node
    fi
    cd $base_dir
    curl -s -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/dashboard.zip
    unzip -q dashboard.zip

    rm -rf $base_dir/dashboard.zip
fi
printf "\n"

# 8. prepare qdrant dir if it does not exist
if [ ! -d "$base_dir/qdrant" ]; then
    printf "[+] Preparing Qdrant directory ...\n"
    mkdir -p $base_dir/qdrant && cd $base_dir/qdrant

    # download qdrant binary
    curl -s -LO https://github.com/qdrant/qdrant/archive/refs/tags/v1.8.1.tar.gz
    # unzip to `qdrant-1.8.1` directory
    tar -xzf v1.8.1.tar.gz
    rm v1.8.1.tar.gz

    # copy the config directory to `qdrant` directory
    cp -r qdrant-1.8.1/config $base_dir/qdrant

    # mkdir -p $base_dir/qdrant/static
    # STATIC_DIR=$base_dir/qdrant/static
    # OPENAPI_FILE=$base_dir/qdrant/qdrant-1.8.1/docs/redoc/master/openapi.json

    # # Get latest dist.zip, assume jq is installed
    # DOWNLOAD_LINK=$(curl --silent "https://api.github.com/repos/qdrant/qdrant-web-ui/releases/latest" | jq -r '.assets[] | select(.name=="dist-qdrant.zip") | .browser_download_url')

    # wget -q -O dist-qdrant.zip $DOWNLOAD_LINK

    # rm -rf "${STATIC_DIR}/"*
    # unzip -q -o dist-qdrant.zip -d "${STATIC_DIR}"
    # rm dist-qdrant.zip
    # cp -r "${STATIC_DIR}/dist/"* "${STATIC_DIR}"
    # rm -rf "${STATIC_DIR}/dist"

    # cp "${OPENAPI_FILE}" "${STATIC_DIR}/openapi.json"

    # remove the `qdrant-1.8.1` directory
    rm -rf qdrant-1.8.1

    # config snapshots directory
    export QDRANT__STORAGE__SNAPSHOTS_PATH=$base_dir/qdrant/snapshots

    echo 'export QDRANT__STORAGE__SNAPSHOTS_PATH='$base_dir'/qdrant/snapshots' >> $HOME/.bashrc

    # start qdrant to create the storage directory structure if it does not exist
    cd $base_dir/qdrant
    nohup $base_dir/bin/qdrant > /dev/null 2>&1 &
    sleep 2
    qdrant_pid=$!
    kill $qdrant_pid

    printf "\n"
fi

# 9. recover from the given qdrant collection snapshot
printf "[+] Recovering the given Qdrant collection snapshot ...\n\n"
cd $cwd
url_snapshot=$(awk -F'"' '/"snapshot":/ {print $4}' config.json)
collection_name=$(basename $url_snapshot)

# start qdrant
cd $base_dir/qdrant
nohup $base_dir/bin/qdrant > /dev/null 2>&1 &
sleep 2
qdrant_pid=$!

response=$(curl -X PUT http://localhost:6333/collections/$collection_name/snapshots/recover \
    -H "Content-Type: application/json" \
    -d "{\"location\":\"$url_snapshot\", \"priority\": null, \"checksum\": null}")
sleep 5

printf "\n"

if echo "$response" | grep -q '"status":"ok"'; then
    printf "Recovery from the collection snapshot is done.\n\n"
else
    printf "Failed to recover from the collection snapshot.\n\n"
fi

# stop qdrant
kill $qdrant_pid

printf "\n>>> Run 'source $HOME/.bashrc' to get the gaia environment ready. To start the gaia services, run the command: ./start.sh <<<\n"

exit 0
