#!/bin/bash

# target name
target=$(uname -m)

snapshot=""
collection_name=""
model_url=""

function print_usage {
    printf "Usage:\n"
    printf "  ./install-gaia.sh\n\n"
    printf "  --snapshot: Url or local path of Qdrant collection snapshot\n"
    printf "  --collection-name: Name for the recovered collection\n"
    printf "  --model-url: Url of GGUF model\n"
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
        --collection-name)
            collection_name="$2"
            shift
            shift
            ;;
        --model-url)
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

# check if the model url is specified or not
if [ -z "$model_url" ]; then
    printf "Please specify a model url using '--model-url' option\n"
    exit 1
fi

if [ -n "$snapshot" ] && [ -z "$collection_name" ]; then
    printf "Please specify a collection name using '--collection-name' option when snapshot is provided\n"
    exit 1
fi

printf "\n"

# 1. Install WasmEdge with wasi-nn_ggml plugin for local user
printf "[+] Installing WasmEdge with wasi-nn_ggml plugin for local user...\n\n"
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

# 2. Install Qdrant at /home/user/bin/qdrant
printf "[+] Installing Qdrant...\n"
qdrant_version="v1.8.1"
if [ "$(uname)" == "Darwin" ]; then
    # Check if "$HOME/bin" directory exists
    if [ ! -d "$HOME/bin" ]; then
        # If not, create it
        mkdir -p $HOME/bin
    fi

    # download qdrant binary
    if [ "$target" = "x86_64" ]; then
        curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-apple-darwin.tar.gz
        tar -xzf qdrant-x86_64-apple-darwin.tar.gz -C $HOME/bin
        rm qdrant-x86_64-apple-darwin.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-apple-darwin.tar.gz
        tar -xzf qdrant-aarch64-apple-darwin.tar.gz -C $HOME/bin
        rm qdrant-aarch64-apple-darwin.tar.gz
    fi

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Check if "$HOME/bin" directory exists
    if [ ! -d "$HOME/bin" ]; then
        # If not, create it
        mkdir -p $HOME/bin
    fi

    # download qdrant statically linked binary
    if [ "$target" = "x86_64" ]; then
        curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-unknown-linux-musl.tar.gz
        tar -xzf qdrant-x86_64-unknown-linux-musl.tar.gz -C $HOME/bin
        rm qdrant-x86_64-unknown-linux-musl.tar.gz
    elif [ "$target" = "aarch64" ]; then
        curl -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-unknown-linux-musl.tar.gz
        tar -xzf qdrant-aarch64-unknown-linux-musl.tar.gz -C $HOME/bin
        rm qdrant-aarch64-unknown-linux-musl.tar.gz
    fi
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    printf "For Windows users, please run this script in WSL.\n"
    exit 1
else
    printf "Only support Linux, MacOS and Windows.\n"
    exit 1
fi
printf "\n"

# 3. Check if "gaia" directory exists in $HOME
if [ ! -d "$HOME/gaia" ]; then
    # If not, create it
    mkdir -p $HOME/gaia
fi
# Set "base_dir" to $HOME/gaia
base_dir="$HOME/gaia"

# 4. Download Mistral 7B GGUF file to $HOME/gaia
model=$(basename $model_url)
if [ -f "$base_dir/$model" ]; then
    printf "[+] Using the cached Mistral-7B-Instruct-v0.2 model file\n"
else
    printf "[+] Downloading $model ...\n"
    curl -L $model_url -o $base_dir/$model
fi
printf "\n"

# 5. Download chatbot-ui
if [ -d "$base_dir/chatbot-ui" ]; then
    printf "[+] Using cached Chatbot web app\n"
else
    printf "[+] Downloading Chatbot web app ...\n"
    cd $base_dir
    files_tarball="https://github.com/second-state/chatbot-ui/releases/latest/download/chatbot-ui.tar.gz"
    curl -L $files_tarball -o chatbot-ui.tar.gz
    if [ $? -ne 0 ]; then
        printf "    \nFailed to download ui tarball. Please manually download from https://github.com/second-state/chatbot-ui/releases/latest/download/chatbot-ui.tar.gz and unzip the "chatbot-ui.tar.gz" to the current directory.\n"
        exit 1
    fi
    tar xzf chatbot-ui.tar.gz
    rm chatbot-ui.tar.gz
fi
printf "\n"

# 6. Download llama-api-server.wasm
printf "[+] Downloading the latest llama-api-server.wasm ...\n"
cd $base_dir
curl -LO https://github.com/LlamaEdge/LlamaEdge/releases/latest/download/llama-api-server.wasm
printf "\n"

# 7. Download create_embeddings.wasm
printf "[+] Downloading the latest create_embeddings.wasm ...\n"
cd $base_dir
curl -LO https://github.com/YuanTony/chemistry-assistant/raw/main/rag-embeddings/create_embeddings.wasm
printf "\n"


# 8. prepare qdrant
if [ ! -d "$base_dir/qdrant" ]; then
    mkdir -p $base_dir/qdrant && cd $base_dir/qdrant

    curl -LO https://github.com/qdrant/qdrant/archive/refs/tags/v1.8.1.tar.gz
    # unzip to `qdrant-1.8.1` directory
    tar -xzf v1.8.1.tar.gz
    rm v1.8.1.tar.gz

    # copy the config directory to `qdrant` directory
    cp -r qdrant-1.8.1/config $base_dir/qdrant

    mkdir -p $base_dir/qdrant/static
    STATIC_DIR=$base_dir/qdrant/static
    OPENAPI_FILE=$base_dir/qdrant/qdrant-1.8.1/docs/redoc/master/openapi.json

    # Get latest dist.zip, assume jq is installed
    DOWNLOAD_LINK=$(curl --silent "https://api.github.com/repos/qdrant/qdrant-web-ui/releases/latest" | jq -r '.assets[] | select(.name=="dist-qdrant.zip") | .browser_download_url')

    wget -q -O dist-qdrant.zip $DOWNLOAD_LINK

    rm -rf "${STATIC_DIR}/"*
    unzip -q -o dist-qdrant.zip -d "${STATIC_DIR}"
    rm dist-qdrant.zip
    cp -r "${STATIC_DIR}/dist/"* "${STATIC_DIR}"
    rm -rf "${STATIC_DIR}/dist"

    cp "${OPENAPI_FILE}" "${STATIC_DIR}/openapi.json"

    # remove the `qdrant-1.8.1` directory
    rm -rf qdrant-1.8.1


    # start qdrant to create the storage directory structure if it does not exist
    cd $base_dir/qdrant
    nohup qdrant > /dev/null 2>&1 &
    sleep 2
    qdrant_pid=$!
    kill $qdrant_pid

    printf "\n"
fi

# 9. recover from the given qdrant collection snapshot
if [ ! -z "$snapshot" ]; then

    cd $base_dir/qdrant

    # start qdrant
    nohup qdrant > /dev/null 2>&1 &
    sleep 2
    qdrant_pid=$!

    response=$(curl -X PUT http://localhost:6333/collections/$collection_name/snapshots/recover \
        -H "Content-Type: application/json" \
        -d "{\"location\":\"$snapshot\", \"priority\": null, \"checksum\": null}")
    sleep 5

    printf "\n"

    if echo "$response" | grep -q '"status":"ok"'; then
        printf "Recovery from the collection snapshot is done.\n\n"
    else
        printf "Failed to recover from the collection snapshot.\n\n"
    fi

    # stop qdrant
    kill $qdrant_pid
fi
