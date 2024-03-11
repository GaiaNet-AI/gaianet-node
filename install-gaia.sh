#!/bin/bash

# target name
target=$(uname -m)


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
model="Mistral-7B-Instruct-v0.2-Q5_K_M.gguf"
if [ -f "$base_dir/$model" ]; then
    printf "[+] Using the cached Mistral-7B-Instruct-v0.2 model file\n"
else
    printf "[+] Downloading $model ...\n"
    curl -L https://huggingface.co/second-state/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/$model -o $base_dir/$model
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
    cd -
fi
printf "\n"

# 6. Download llama-api-server.wasm
printf "[+] Downloading the latest llama-api-server.wasm ...\n"
cd $base_dir
curl -LO https://github.com/LlamaEdge/LlamaEdge/releases/latest/download/llama-api-server.wasm
cd -
printf "\n"

# 7. Download create_embeddings.wasm
printf "[+] Downloading the latest create_embeddings.wasm ...\n"
cd $base_dir
curl -LO https://github.com/YuanTony/chemistry-assistant/raw/main/rag-embeddings/create_embeddings.wasm
cd -
printf "\n"

# 8. Download a vector collection into qdrant/storage
printf "[+] Downloading a vector collection into qdrant/storage ...\n"
if [ ! -d "$base_dir/qdrant" ]; then
    mkdir -p $base_dir/qdrant
fi
if [ ! -d "$base_dir/qdrant/storage" ]; then
    mkdir -p $base_dir/qdrant/storage
fi
cd $base_dir/qdrant/storage
curl -L "https://www.dropbox.com/scl/fi/2k00qjbr3rhq9c89kh2ha/qdrant_storage.zip?rlkey=1ybvyb9ubl49va7ig2e5jhb4t&e=2&dl=0" -o qdrant_storage.zip
unzip -q qdrant_storage.zip
rm qdrant_storage.zip
cd -
printf "\n"
