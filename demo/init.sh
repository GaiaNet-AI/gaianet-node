# !/bin/bash

# target name
target=$(uname -m)


# represents the directory where the script is located
cwd=$(pwd)

# 0: do not reinstall, 1: reinstall
reinstall=0

function print_usage {
    printf "Usage:\n"
    printf "  ./init.sh\n\n"
    printf "  --reinstall: install and download all required deps\n"
    printf "  --help: Print usage\n"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --reinstall)
            reinstall=1
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

# Set "gaianet_base_dir" to $HOME/gaianet
gaianet_base_dir="$HOME/gaianet"

# if need to reinstall, remove the $gaianet_base_dir directory
if [ "$reinstall" -eq 1 ] && [ -d "$gaianet_base_dir" ]; then
    printf "[+] Removing the existing $gaianet_base_dir directory ...\n\n"
    rm -rf $gaianet_base_dir
fi

# Check if $gaianet_base_dir directory exists
if [ ! -d $gaianet_base_dir ]; then
    mkdir $gaianet_base_dir
fi

# 1. check if config.json exists or not
cd $gaianet_base_dir
if [ ! -f "$gaianet_base_dir/config.json" ]; then
    printf "[+] Downloading config.json ...\n\n"
    curl -s -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/demo/config.json
fi

# 2. Install WasmEdge with wasi-nn_ggml plugin for local user
if ! command -v wasmedge >/dev/null 2>&1 || [ "$reinstall" -eq 1 ]; then
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
else
    wasmedge_version=$(wasmedge --version)
    printf "[+] WasmEdge Runtime %s is already installed.\n" "$wasmedge_version"
fi
printf "\n"

# 3. Install Qdrant at $HOME/gaianet/bin

# Check if "$gaianet_base_dir/bin" directory exists
if [ ! -d "$gaianet_base_dir/bin" ]; then
    # If not, create it
    mkdir -p $gaianet_base_dir/bin
fi
if [ ! -f "$gaianet_base_dir/bin/qdrant" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Installing Qdrant binary...\n"

    qdrant_version="v1.8.1"
    if [ "$(uname)" == "Darwin" ]; then
        # download qdrant binary
        if [ "$target" = "x86_64" ]; then
            curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-apple-darwin.tar.gz
            tar -xzf qdrant-x86_64-apple-darwin.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-x86_64-apple-darwin.tar.gz
        elif [ "$target" = "arm64" ]; then
            curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-apple-darwin.tar.gz
            tar -xzf qdrant-aarch64-apple-darwin.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-aarch64-apple-darwin.tar.gz
        fi

        # Check if the path is not in $PATH
        path_to_check="$HOME/gaianet/bin"
        if [[ ":$PATH:" != *":$path_to_check:"* ]]; then
            echo 'export PATH=$PATH:'$gaianet_base_dir'/bin' >> $HOME/.bashrc
        fi

    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # download qdrant statically linked binary
        if [ "$target" = "x86_64" ]; then
            curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-unknown-linux-musl.tar.gz
            tar -xzf qdrant-x86_64-unknown-linux-musl.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-x86_64-unknown-linux-musl.tar.gz
        elif [ "$target" = "aarch64" ]; then
            curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-unknown-linux-musl.tar.gz
            tar -xzf qdrant-aarch64-unknown-linux-musl.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-aarch64-unknown-linux-musl.tar.gz
        fi

        # Check if the path is not in $PATH
        path_to_check="$HOME/gaianet/bin"
        if [[ ":$PATH:" != *":$path_to_check:"* ]]; then
            echo 'export PATH=$PATH:'$gaianet_base_dir'/bin' >> $HOME/.bashrc
        fi

    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        printf "For Windows users, please run this script in WSL.\n"
        exit 1
    else
        printf "Only support Linux, MacOS and Windows.\n"
        exit 1
    fi

else
    printf "[+] Using the cached Qdrant binary ...\n"
fi
printf "\n"

# 4. Download GGUF chat model to $HOME/gaianet
url_chat_model=$(awk -F'"' '/"chat":/ {print $4}' $gaianet_base_dir/config.json)
if [[ $url_chat_model =~ ^https://huggingface\.co/second-state ]]; then
    chat_model=$(basename $url_chat_model)

    if [ -f "$gaianet_base_dir/$chat_model" ]; then
        printf "[+] Using the cached chat model: $chat_model\n"
    else
        printf "[+] Downloading $chat_model ...\n\n"
        curl -L $url_chat_model -o $gaianet_base_dir/$chat_model
    fi
    printf "\n"
else
    printf "Error: the chat model is not from https://huggingface.co/second-state\n"
    exit 1
fi

# 5. Download GGUF embedding model to $HOME/gaianet
url_embedding_model=$(awk -F'"' '/"embedding":/ {print $4}' $gaianet_base_dir/config.json)
if [[ $url_embedding_model =~ ^https://huggingface\.co/second-state ]]; then
    embedding_model=$(basename $url_embedding_model)

    if [ -f "$gaianet_base_dir/$embedding_model" ]; then
        printf "[+] Using the cached embedding model: $embedding_model\n"
    else
        printf "[+] Downloading $embedding_model ...\n\n"
        curl -L $url_embedding_model -o $gaianet_base_dir/$embedding_model
    fi
    printf "\n"
else
    printf "Error: the embedding model is not from https://huggingface.co/second-state\n"
    exit 1
fi

# 6. Download llama-api-server.wasm
cd $gaianet_base_dir
if [ ! -f "$gaianet_base_dir/llama-api-server.wasm" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading the llama-api-server.wasm ...\n\n"

    curl -LO https://github.com/LlamaEdge/LlamaEdge/raw/feat-server-multi-models/api-server/llama-api-server.wasm

else
    printf "[+] Using the cached llama-api-server.wasm ...\n"
fi
printf "\n"

# 7. Download dashboard to $HOME/gaianet
if [ ! -d "$gaianet_base_dir/dashboard" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading dashboard ...\n"
    if [ -d "$gaianet_base_dir/gaianet-node" ]; then
        rm -rf $gaianet_base_dir/gaianet-node
    fi
    cd $gaianet_base_dir
    curl -s -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/dashboard.zip
    unzip -q dashboard.zip

    rm -rf $gaianet_base_dir/dashboard.zip
else
    printf "[+] Using cached dashboard ...\n"
fi
printf "\n"

# 8. prepare qdrant dir if it does not exist
if [ ! -d "$gaianet_base_dir/qdrant" ]; then
    printf "[+] Preparing Qdrant directory ...\n"
    mkdir -p $gaianet_base_dir/qdrant && cd $gaianet_base_dir/qdrant

    # download qdrant binary
    curl -s -LO https://github.com/qdrant/qdrant/archive/refs/tags/v1.8.1.tar.gz
    # unzip to `qdrant-1.8.1` directory
    tar -xzf v1.8.1.tar.gz
    rm v1.8.1.tar.gz

    # copy the config directory to `qdrant` directory
    cp -r qdrant-1.8.1/config .

    # remove the `qdrant-1.8.1` directory
    rm -rf qdrant-1.8.1

    # start qdrant to create the storage directory structure if it does not exist
    nohup $gaianet_base_dir/bin/qdrant > init-log.txt 2>&1 &
    sleep 2
    qdrant_pid=$!
    kill $qdrant_pid

    printf "\n"
fi


# 9. recover from the given qdrant collection snapshot =======================
printf "[+] Recovering the given Qdrant collection snapshot ...\n\n"
cd $gaianet_base_dir
url_snapshot=$(awk -F'"' '/"snapshot":/ {print $4}' config.json)
collection_name=$(basename $url_snapshot)
collection_stem=$(basename "$collection_name" .snapshot)

# start qdrant
cd $gaianet_base_dir/qdrant
nohup $gaianet_base_dir/bin/qdrant > init-log.txt 2>&1 &
sleep 2
qdrant_pid=$!

response=$(curl -X PUT http://localhost:6333/collections/paris/snapshots/recover \
    -H "Content-Type: application/json" \
    -d "{\"location\":\"$url_snapshot\", \"priority\": \"snapshot\", \"checksum\": null}")
sleep 5

# stop qdrant
kill $qdrant_pid

printf "\n"

if echo "$response" | grep -q '"status":"ok"'; then
    printf "    Recovery is done.\n\n"
else
    printf "    Failed to recover from the collection snapshot. $response \n\n"
fi
# ======================================================================================

# Check if the directory exists, if not, create it
if [ ! -d "$gaianet_base_dir/frp" ]; then
    mkdir -p $gaianet_base_dir/frp
fi

# 10. Install frpc at $HOME/gaianet/bin
printf "[+] Installing frp...\n\n"
# Check if the directory exists, if not, create it
if [ ! -d "$gaianet_base_dir/frp" ]; then
    mkdir -p $gaianet_base_dir/frp
fi

frp_version="v0.1.0-alpha.1"
if [ "$(uname)" == "Darwin" ]; then
    # download frp binary
    if [ "$target" = "x86_64" ]; then
        curl -LO https://github.com/GaiaNet-AI/frp/releases/download/$frp_version/frp_${frp_version}_darwin_amd64.tar.gz
        tar -xzf frp_${frp_version}_darwin_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/frp
        rm frp_${frp_version}_darwin_amd64.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl -LO https://github.com/GaiaNet-AI/frp/releases/download/$frp_version/frp_${frp_version}_darwin_arm64.tar.gz
        tar -xzf frp_${frp_version}_darwin_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/frp
        rm frp_${frp_version}_darwin_arm64.tar.gz
    fi
    if ! echo $PATH | grep -q "$HOME/gaianet/bin"; then
        echo 'export PATH=$PATH:'$gaianet_base_dir'/bin' >> $HOME/.bashrc
    fi

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # download qdrant statically linked binary
    if [ "$target" = "x86_64" ]; then
        curl -LO https://github.com/GaiaNet-AI/frp/releases/download/$frp_version/frp_${frp_version}_linux_amd64.tar.gz
        tar -xzf frp_${frp_version}_linux_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/frp
        rm frp_${frp_version}_linux_amd64.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl -LO https://github.com/GaiaNet-AI/frp/releases/download/$frp_version/frp_${frp_version}_linux_arm64.tar.gz
        tar -xzf frp_${frp_version}_linux_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/frp
        rm frp_${frp_version}_linux_arm64.tar.gz
    fi
    if ! echo $PATH | grep -q "$HOME/gaianet/bin"; then
        echo 'export PATH=$PATH:'$gaianet_base_dir'/bin' >> $HOME/.bashrc
    fi

elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    printf "For Windows users, please run this script in WSL.\n"
    exit 1
else
    printf "Only support Linux, MacOS and Windows.\n"
    exit 1
fi
printf "\n"

# Copy frpc from $gaianet_base_dir/frp to $gaianet_base_dir/bin
cp $gaianet_base_dir/frp/frpc $gaianet_base_dir/bin/

# 11. Download frpc.toml
curl -L https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/demo/frpc.toml -o $gaianet_base_dir/frp/frpc.toml

printf "\n>>> Run 'source $HOME/.bashrc' to get the gaia environment ready. To start the gaia services, run the command: ./start.sh <<<\n"

exit 0
