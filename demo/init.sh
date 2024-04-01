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
            curl --progress-bar -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-apple-darwin.tar.gz
            tar -xzf qdrant-x86_64-apple-darwin.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-x86_64-apple-darwin.tar.gz
        elif [ "$target" = "arm64" ]; then
            curl --progress-bar -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-apple-darwin.tar.gz
            tar -xzf qdrant-aarch64-apple-darwin.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-aarch64-apple-darwin.tar.gz
        fi

    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # download qdrant statically linked binary
        if [ "$target" = "x86_64" ]; then
            curl --progress-bar -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-unknown-linux-musl.tar.gz
            tar -xzf qdrant-x86_64-unknown-linux-musl.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-x86_64-unknown-linux-musl.tar.gz
        elif [ "$target" = "aarch64" ]; then
            curl --progress-bar -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-unknown-linux-musl.tar.gz
            tar -xzf qdrant-aarch64-unknown-linux-musl.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-aarch64-unknown-linux-musl.tar.gz
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
chat_model=$(basename $url_chat_model)
if [ -f "$gaianet_base_dir/$chat_model" ]; then
    printf "[+] Using the cached chat model: $chat_model\n"
else
    printf "[+] Downloading $chat_model ...\n\n"
    curl --progress-bar -L $url_chat_model -o $gaianet_base_dir/$chat_model
fi
printf "\n"

# 5. Download GGUF embedding model to $HOME/gaianet
url_embedding_model=$(awk -F'"' '/"embedding":/ {print $4}' $gaianet_base_dir/config.json)
embedding_model=$(basename $url_embedding_model)
if [ -f "$gaianet_base_dir/$embedding_model" ]; then
    printf "[+] Using the cached embedding model: $embedding_model\n"
else
    printf "[+] Downloading $embedding_model ...\n\n"
    curl --progress-bar -L $url_embedding_model -o $gaianet_base_dir/$embedding_model
fi
printf "\n"


# 6. Download llama-api-server.wasm
cd $gaianet_base_dir
if [ ! -f "$gaianet_base_dir/llama-api-server.wasm" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading the llama-api-server.wasm ...\n\n"

    curl --progress-bar -LO https://github.com/LlamaEdge/LlamaEdge/releases/latest/download/llama-api-server.wasm

else
    printf "[+] Using the cached llama-api-server.wasm ...\n"
fi
printf "\n"

# 7. Download dashboard to $HOME/gaianet
if ! command -v unzip &> /dev/null
then
    echo "unzip could not be found, please install it."
    exit
fi

if [ ! -d "$gaianet_base_dir/dashboard" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading dashboard ...\n"
    if [ -d "$gaianet_base_dir/gaianet-node" ]; then
        rm -rf $gaianet_base_dir/gaianet-node
    fi
    cd $gaianet_base_dir
    curl --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/dashboard.zip
    unzip -q dashboard.zip

    rm -rf $gaianet_base_dir/dashboard.zip
else
    printf "[+] Using cached dashboard ...\n"
fi
printf "\n"

# 7.5 Generate node ID and copy config to dashboard
if [ ! -f "$gaianet_base_dir/registry.wasm" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading the registry.wasm ...\n\n"
    curl -s -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/utils/registry/registry.wasm
else
    printf "[+] Using cached registry ...\n\n"
fi
printf "[+] Generating node ID ...\n"
wasmedge --dir .:. registry.wasm
printf "\n"

# 8. prepare qdrant dir if it does not exist
if [ ! -d "$gaianet_base_dir/qdrant" ]; then
    printf "[+] Preparing Qdrant directory ...\n"
    mkdir -p $gaianet_base_dir/qdrant && cd $gaianet_base_dir/qdrant

    # download qdrant binary
    curl --progress-bar -LO https://github.com/qdrant/qdrant/archive/refs/tags/v1.8.1.tar.gz
    # unzip to `qdrant-1.8.1` directory
    tar -xzf v1.8.1.tar.gz
    rm v1.8.1.tar.gz

    # copy the config directory to `qdrant` directory
    cp -r qdrant-1.8.1/config .

    # remove the `qdrant-1.8.1` directory
    rm -rf qdrant-1.8.1

    # check 6333 port is in use or not
    if [ "$(uname)" == "Darwin" ]; then
        if lsof -Pi :6333 -sTCP:LISTEN -t >/dev/null ; then
            printf "    Port 6333 is in use. Stopping the process on 6333 ...\n\n"
            pid=$(lsof -t -i:6333)
            kill -9 $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        if netstat -tuln | grep -q ':6333'; then
            printf "    Port 6333 is in use. Stopping the process on 6333 ...\n\n"
            pid=$(fuser -n tcp 6333 2> /dev/null)
            kill -9 $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        printf "For Windows users, please run this script in WSL.\n"
        exit 1
    else
        printf "Only support Linux, MacOS and Windows.\n"
        exit 1
    fi

    # start qdrant to create the storage directory structure if it does not exist
    nohup $gaianet_base_dir/bin/qdrant > init-log.txt 2>&1 &
    sleep 2
    qdrant_pid=$!
    kill $qdrant_pid

    printf "\n"
fi

# 9. recover from the given qdrant collection snapshot =======================
cd $gaianet_base_dir
url_snapshot=$(awk -F'"' '/"snapshot":/ {print $4}' config.json)
url_document=$(awk -F'"' '/"document":/ {print $4}' config.json)

if [ -n "$url_snapshot" ]; then
    printf "[+] Recovering the given Qdrant collection snapshot ...\n\n"
    curl --progress-bar -L $url_snapshot -o default.snapshot
    # collection_name=$(basename $url_snapshot)
    # collection_stem=$(basename "$collection_name" .snapshot)

    # check 6333 port is in use or not
    if [ "$(uname)" == "Darwin" ]; then
        if lsof -Pi :6333 -sTCP:LISTEN -t >/dev/null ; then
            printf "    Port 6333 is in use. Stopping the process on 6333 ...\n\n"
            pid=$(lsof -t -i:6333)
            kill -9 $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        if netstat -tuln | grep -q ':6333'; then
            printf "    Port 6333 is in use. Stopping the process on 6333 ...\n\n"
            pid=$(fuser -n tcp 6333 2> /dev/null)
            kill -9 $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        printf "For Windows users, please run this script in WSL.\n"
        exit 1
    else
        printf "Only support Linux, MacOS and Windows.\n"
        exit 1
    fi

    # start qdrant
    cd $gaianet_base_dir/qdrant
    nohup $gaianet_base_dir/bin/qdrant > $gaianet_base_dir/init-log.txt 2>&1 &
    sleep 2
    qdrant_pid=$!

    response=$(curl -s -X POST 'http://localhost:6333/collections/default/snapshots/upload?priority=snapshot' \
        -H 'Content-Type:multipart/form-data' \
        -F 'snapshot=@default.snapshot')
    # response=$(curl -s -X PUT http://localhost:6333/collections/default/snapshots/recover \
    #     -H "Content-Type: application/json" \
    #     -d "{\"location\":\"$url_snapshot\", \"priority\": \"snapshot\", \"checksum\": null}")
    sleep 5

    # stop qdrant
    kill $qdrant_pid

    printf "\n"

    if echo "$response" | grep -q '"status":"ok"'; then
        printf "    Recovery is done.\n"
    else
        printf "    Failed to recover from the collection snapshot. $response \n"
        exit 1
    fi

elif [ -n "$url_document" ]; then
    printf "[+] Creating a Qdrant collection from the given document ...\n\n"

    # 9.1. start a Qdrant instance to remove the 'default' collection if it exists
    printf "    * Remove 'default' collection if it exists ...\n\n"
    if [ "$(uname)" == "Darwin" ]; then
        if lsof -Pi :6333 -sTCP:LISTEN -t >/dev/null ; then
            printf "    Port 6333 is in use. Stopping the process on 6333 ...\n\n"
            pid=$(lsof -t -i:6333)
            kill -9 $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        if netstat -tuln | grep -q ':6333'; then
            printf "    Port 6333 is in use. Stopping the process on 6333 ...\n\n"
            pid=$(fuser -n tcp 6333 2> /dev/null)
            kill -9 $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        printf "For Windows users, please run this script in WSL.\n"
        exit 1
    else
        printf "Only support Linux, MacOS and Windows.\n"
        exit 1
    fi

    qdrant_executable="$gaianet_base_dir/bin/qdrant"
    if [ -f "$qdrant_executable" ]; then
        cd $gaianet_base_dir/qdrant
        nohup $qdrant_executable > init-log.txt 2>&1 &
        sleep 2
        qdrant_pid=$!
        echo $qdrant_pid > $gaianet_base_dir/qdrant.pid

        # remove the 'default' collection if it exists
        del_response=$(curl -s -X DELETE http://localhost:6333/collections/default \
            -H "Content-Type: application/json")
        status=$(echo "$del_response" | grep -o '"status":"[^"]*"' | cut -d':' -f2 | tr -d '"')
        if [ "$status" != "ok" ]; then
            printf "    Failed to remove the 'default' collection. $del_response\n\n"
            exit 1
        fi
    else
        printf "Qdrant binary not found at $qdrant_executable\n\n"
        exit 1
    fi

    # 9.2. start a Qdrant instance to create the 'default' collection from the given document
    printf "    * Starting LlamaEdge API Server ...\n\n"

    # parse cli options for chat model
    cd $gaianet_base_dir
    url_chat_model=$(awk -F'"' '/"chat":/ {print $4}' config.json)
    # gguf filename
    chat_model_name=$(basename $url_chat_model)
    # stem part of the filename
    chat_model_stem=$(basename "$chat_model_name" .gguf)
    # parse context size for chat model
    chat_ctx_size=$(awk -F'"' '/"chat_ctx_size":/ {print $4}' config.json)
    # parse prompt type for chat model
    prompt_type=$(awk -F'"' '/"prompt_template":/ {print $4}' config.json)
    # parse reverse prompt for chat model
    reverse_prompt=$(awk -F'"' '/"reverse_prompt":/ {print $4}' config.json)
    # parse cli options for embedding model
    url_embedding_model=$(awk -F'"' '/"embedding":/ {print $4}' config.json)
    # gguf filename
    embedding_model_name=$(basename $url_embedding_model)
    # stem part of the filename
    embedding_model_stem=$(basename "$embedding_model_name" .gguf)
    # parse context size for embedding model
    embedding_ctx_size=$(awk -F'"' '/"embedding_ctx_size":/ {print $4}' config.json)
    # parse port for LlamaEdge API Server
    llamaedge_port=$(awk -F'"' '/"llamaedge_port":/ {print $4}' config.json)

    if [ "$(uname)" == "Darwin" ]; then
        if lsof -Pi :$llamaedge_port -sTCP:LISTEN -t >/dev/null ; then
            printf "    Port $llamaedge_port is in use. Stopping the process on $llamaedge_port ...\n\n"
            pid=$(lsof -t -i:$llamaedge_port)
            kill $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        if netstat -tuln | grep -q ":$llamaedge_port"; then
            printf "    Port $llamaedge_port is in use. Stopping the process on $llamaedge_port ...\n\n"
            pid=$(fuser -n tcp $llamaedge_port 2> /dev/null)
            kill $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        printf "For Windows users, please run this script in WSL.\n"
        exit 1
    else
        printf "Only support Linux, MacOS and Windows.\n"
        exit 1
    fi

    cd $gaianet_base_dir
    llamaedge_wasm="$gaianet_base_dir/llama-api-server.wasm"
    if [ ! -f "$llamaedge_wasm" ]; then
        printf "LlamaEdge wasm not found at $llamaedge_wasm\n"
        exit 1
    fi

    # command to start LlamaEdge API Server
    cd $gaianet_base_dir
    cmd="wasmedge --dir .:. \
    --nn-preload default:GGML:AUTO:$chat_model_name \
    --nn-preload embedding:GGML:AUTO:$embedding_model_name \
    llama-api-server.wasm -p $prompt_type \
    --model-name $chat_model_stem,$embedding_model_stem \
    --ctx-size $chat_ctx_size,$embedding_ctx_size \
    --qdrant-url http://127.0.0.1:6333 \
    --qdrant-collection-name "default" \
    --qdrant-limit 3 \
    --qdrant-score-threshold 0.4 \
    --web-ui ./dashboard \
    --socket-addr 0.0.0.0:$llamaedge_port \
    --log-prompts \
    --log-stat"

    # Add reverse prompt if it exists
    if [ -n "$reverse_prompt" ]; then
        cmd="$cmd --reverse-prompt \"${reverse_prompt}\""
    fi

    # printf "    Run the following command to start the LlamaEdge API Server:\n\n"
    # printf "    %s\n\n" "$cmd"

    nohup $cmd > init-log.txt 2>&1 &
    sleep 2
    llamaedge_pid=$!
    echo $llamaedge_pid > $gaianet_base_dir/llamaedge.pid

    # (1) download the document
    printf "    * Downloading the document ...\n\n"
    cd $gaianet_base_dir
    doc_filename=$(basename $url_document)
    curl -s $url_document -o $doc_filename

    if [[ $doc_filename != *.txt ]] && [[ $doc_filename != *.md ]]; then
        printf "Error: the document to upload should be a file with 'txt' or 'md' extension.\n"

        # stop the Qdrant instance
        if [ -f "$gaianet_base_dir/qdrant.pid" ]; then
            # printf "[+] Stopping Qdrant instance ...\n"
            kill $(cat $gaianet_base_dir/qdrant.pid)
            rm $gaianet_base_dir/qdrant.pid
        fi

        # stop the api-server
        if [ -f "$gaianet_base_dir/llamaedge.pid" ]; then
            # printf "[+] Stopping API server ...\n"
            kill $(cat $gaianet_base_dir/llamaedge.pid)
            rm $gaianet_base_dir/llamaedge.pid
        fi

        # stop gaianet-domain
        if [ -f "$gaianet_base_dir/gaianet-domain.pid" ]; then
            # printf "[+] Stopping gaianet-domain ...\n"
            kill $(cat $gaianet_base_dir/gaianet-domain.pid)
            rm $gaianet_base_dir/gaianet-domain.pid
        fi

        exit 1
    fi


    # (2) upload the document to api-server via the `/v1/files` endpoint
    printf "    * Uploading the document to LlamaEdge API Server ...\n"
    doc_response=$(curl -s -X POST http://127.0.0.1:$llamaedge_port/v1/files -F "file=@$doc_filename")
    id=$(echo "$doc_response" | grep -o '"id":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    filename=$(echo "$doc_response" | grep -o '"filename":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    rm $doc_filename
    printf "\n"

    # (3) chunk the document
    printf "    * Chunking the document ...\n"
    chunk_response=$(curl -s -X POST http://127.0.0.1:$llamaedge_port/v1/chunks -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"$id\",\"filename\":\"$filename\"}")

    chunks=$(echo $chunk_response | grep -o '"chunks":\[[^]]*\]' | sed 's/"chunks"://')

    printf "\n"

    # (4) compute the embeddings for the chunks and upload them to the Qdrant instance
    printf "    * Computing the embeddings and uploading them to the Qdrant instance ...\n"

    data={\"model\":\"$embedding_model_stem\",\"input\":"$chunks"}

    embedding_response=$(curl -s -X POST http://127.0.0.1:$llamaedge_port/v1/embeddings -H "accept: application/json" -H "Content-Type: application/json" -d "$data")

    printf "\n"

    # stop the Qdrant instance
    if [ -f "$gaianet_base_dir/qdrant.pid" ]; then
        # printf "[+] Stopping Qdrant instance ...\n"
        kill $(cat $gaianet_base_dir/qdrant.pid)
        rm $gaianet_base_dir/qdrant.pid
    fi

    # stop the api-server
    if [ -f "$gaianet_base_dir/llamaedge.pid" ]; then
        # printf "[+] Stopping API server ...\n"
        kill $(cat $gaianet_base_dir/llamaedge.pid)
        rm $gaianet_base_dir/llamaedge.pid
    fi


else
    echo "Please set 'snapshot' or 'document' field in config.json"
fi
printf "\n"

# ======================================================================================

# 10. Install gaianet-domain at $HOME/gaianet/bin
printf "[+] Installing gaianet-domain...\n\n"
# Check if the directory exists, if not, create it
if [ ! -d "$gaianet_base_dir/gaianet-domain" ]; then
    mkdir -p $gaianet_base_dir/gaianet-domain
fi

gaianet_domain_version="v0.1.0-alpha.1"
if [ "$(uname)" == "Darwin" ]; then
    # download gaianet-domain binary
    if [ "$target" = "x86_64" ]; then
        curl --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz
        tar -xzf gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz
        tar -xzf gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz
    fi

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # download gaianet-domain statically linked binary
    if [ "$target" = "x86_64" ]; then
        curl --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz
        tar --warning=no-unknown-keyword -xzf gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz
        tar --warning=no-unknown-keyword -xzf gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz
    fi

elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    printf "For Windows users, please run this script in WSL.\n"
    exit 1
else
    printf "Only support Linux, MacOS and Windows.\n"
    exit 1
fi
printf "\n"

# Copy frpc from $gaianet_base_dir/gaianet-domain to $gaianet_base_dir/bin
cp $gaianet_base_dir/gaianet-domain/frpc $gaianet_base_dir/bin/

# 11. Download frpc.toml, generate a subdomain and print it
curl -s -L https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/demo/frpc.toml -o $gaianet_base_dir/gaianet-domain/frpc.toml

# Read address from config.json as node subdomain
subdomain=$(awk -F'"' '/"address":/ {print $4}' $gaianet_base_dir/config.json)

# Check if the subdomain was read correctly
if [ -z "$subdomain" ]; then
    echo "Failed to read the address from config.json."
    exit 1
fi

# Read domain from config.json
gaianet_domain=$(awk -F'"' '/"domain":/ {print $4}' $gaianet_base_dir/config.json)

# Resolve the IP address of the domain
ip_address=$(dig +short a.$gaianet_domain | tr -d '\n')

# Check if the IP address was resolved correctly
if [ -z "$ip_address" ]; then
    echo "Failed to resolve the IP address of the domain."
    exit 1
fi

# Replace the serverAddr & subdomain in frpc.toml
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sed_i_cmd="sed -i"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    sed_i_cmd="sed -i ''"
else
    echo "Unsupported OS"
    exit 1
fi

$sed_i_cmd "s/subdomain = \".*\"/subdomain = \"$subdomain\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
$sed_i_cmd "s/serverAddr = \".*\"/serverAddr = \"$ip_address\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
$sed_i_cmd "s/name = \".*\"/name = \"$subdomain.$gaianet_domain\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml

# Remove all files in the directory except for frpc and frpc.toml
find $gaianet_base_dir/gaianet-domain -type f -not -name 'frpc' -not -name 'frpc.toml' -exec rm -f {} \;

printf "The subdomain for frpc is: https://$subdomain.$gaianet_domain\n"

printf "Your node ID is $subdomain Please register it in your portal account to receive awards!\n"

exit 0
