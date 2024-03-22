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
if [[ $url_chat_model =~ ^https://huggingface\.co/second-state ]] || [[ $url_chat_model =~ ^https://huggingface\.co/gaianet ]]; then
    chat_model=$(basename $url_chat_model)

    if [ -f "$gaianet_base_dir/$chat_model" ]; then
        printf "[+] Using the cached chat model: $chat_model\n"
    else
        printf "[+] Downloading $chat_model ...\n\n"
        curl -L $url_chat_model -o $gaianet_base_dir/$chat_model
    fi
    printf "\n"
else
    printf "Error: the chat model is not from https://huggingface.co/second-state or or https://huggingface.co/gaianet\n"
    exit 1
fi

# 5. Download GGUF embedding model to $HOME/gaianet
url_embedding_model=$(awk -F'"' '/"embedding":/ {print $4}' $gaianet_base_dir/config.json)
if [[ $url_embedding_model =~ ^https://huggingface\.co/second-state ]] || [[ $url_embedding_model =~ ^https://huggingface\.co/gaianet ]]; then
    embedding_model=$(basename $url_embedding_model)

    if [ -f "$gaianet_base_dir/$embedding_model" ]; then
        printf "[+] Using the cached embedding model: $embedding_model\n"
    else
        printf "[+] Downloading $embedding_model ...\n\n"
        curl -L $url_embedding_model -o $gaianet_base_dir/$embedding_model
    fi
    printf "\n"
else
    printf "Error: the embedding model is not from https://huggingface.co/second-state\n or or https://huggingface.co/gaianet\n"
    exit 1
fi

# 6. Download llama-api-server.wasm
cd $gaianet_base_dir
if [ ! -f "$gaianet_base_dir/llama-api-server.wasm" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading the llama-api-server.wasm ...\n\n"

    curl -LO https://github.com/LlamaEdge/LlamaEdge/raw/feat-files-endpoint/api-server/llama-api-server.wasm

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
cd $gaianet_base_dir
url_snapshot=$(awk -F'"' '/"snapshot":/ {print $4}' config.json)
url_document=$(awk -F'"' '/"document":/ {print $4}' config.json)

if [ -n "$url_snapshot" ]; then
    printf "[+] Recovering the given Qdrant collection snapshot ...\n\n"
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
        printf "    Recovery is done.\n"
    else
        printf "    Failed to recover from the collection snapshot. $response \n"
    fi

elif [ -n "$url_document" ]; then
    printf "[+] Creating a Qdrant collection from the given document ...\n\n"

    # 9.1. start a Qdrant instance to remove the 'paris' collection if it exists
    printf "    * Remove 'paris' collection if it exists ...\n\n"
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
        nohup $qdrant_executable > start-log.txt 2>&1 &
        sleep 2
        qdrant_pid=$!
        echo $qdrant_pid > $gaianet_base_dir/qdrant.pid

        # remove the 'paris' collection if it exists
        del_response=$(curl -X DELETE http://localhost:6333/collections/paris \
            -H "Content-Type: application/json")
        status=$(echo "$del_response" | grep -o '"status":"[^"]*"' | cut -d':' -f2 | tr -d '"')
        if [ "$status" != "ok" ]; then
            printf "    Failed to remove the 'paris' collection. $del_response\n\n"
            exit 1
        fi
    else
        printf "Qdrant binary not found at $qdrant_executable\n"
        exit 1
    fi
    printf "\n"

    # 9.2. start a Qdrant instance to create the 'paris' collection from the given document
    printf "    * Starting LlamaEdge API Server ...\n\n"
    if [ "$(uname)" == "Darwin" ]; then
        if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
            printf "    Port 8080 is in use. Stopping the process on 8080 ...\n\n"
            pid=$(lsof -t -i:8080)
            kill -9 $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        if netstat -tuln | grep -q ':8080'; then
            printf "    Port 8080 is in use. Stopping the process on 8080 ...\n\n"
            pid=$(fuser -n tcp 8080 2> /dev/null)
            kill -9 $pid
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        printf "For Windows users, please run this script in WSL.\n"
        exit 1
    else
        printf "Only support Linux, MacOS and Windows.\n"
        exit 1
    fi

    # parse cli options for chat model
    cd $gaianet_base_dir
    url_chat_model=$(awk -F'"' '/"chat":/ {print $4}' config.json)

    if [[ $url_chat_model =~ ^https://huggingface\.co/second-state ]] || [[ $url_chat_model =~ ^https://huggingface\.co/gaianet ]]; then
        # gguf filename
        chat_model_name=$(basename $url_chat_model)
        # stem part of the filename
        chat_model_stem=$(basename "$chat_model_name" .gguf)
        # repo url
        repo_chat_model=$(echo "$url_chat_model" | awk -F'/' '{print $1"//"$3"/"$4"/"$5}')

        # README.md url
        readme_url="$repo_chat_model/resolve/main/README.md"

        # Download the README.md file
        curl -s $readme_url -o README.md

        # Extract the "Prompt type: xxxx" line
        prompt_type_line=$(grep -i "Prompt type:" README.md)

        # Extract the xxxx part
        prompt_type=$(echo $prompt_type_line | cut -d'`' -f2 | xargs)

        # Check if "Reverse prompt" exists
        if grep -q "Reverse prompt:" README.md; then
            # Extract the "Reverse prompt: xxxx" line
            reverse_prompt_line=$(grep -i "Reverse prompt:" README.md)

            # Extract the xxxx part
            reverse_prompt=$(echo $reverse_prompt_line | cut -d'`' -f2 | xargs)
        fi

        # Clean up
        rm README.md
    else
        printf "Error: the chat model is not from https://huggingface.co/second-state or https://huggingface.co/gaianet\n"
        exit 1
    fi

    # parse cli options for embedding model
    cd $gaianet_base_dir
    url_embedding_model=$(awk -F'"' '/"embedding":/ {print $4}' config.json)
    if [[ $url_embedding_model =~ ^https://huggingface\.co/second-state ]] || [[ $url_embedding_model =~ ^https://huggingface\.co/gaianet ]]; then
        # gguf filename
        embedding_model_name=$(basename $url_embedding_model)
        # stem part of the filename
        embedding_model_stem=$(basename "$embedding_model_name" .gguf)
        # repo url
        repo_chat_model=$(echo "$url_embedding_model" | awk -F'/' '{print $1"//"$3"/"$4"/"$5}')
        # README.md url
        readme_url="$repo_chat_model/resolve/main/README.md"

        # Download the README.md file
        curl -s $readme_url -o README.md

        # Extract the "Prompt type: xxxx" line
        context_size_line=$(grep -i "Context size:" README.md)

        # Extract the xxxx part
        embedding_ctx_size=$(echo $context_size_line | cut -d'`' -f2 | xargs)

        # Clean up
        rm README.md
    else
        printf "Error: the embedding model is not from https://huggingface.co/second-state\n or https://huggingface.co/gaianet\n"
        exit 1
    fi

    cd $gaianet_base_dir
    llamaedge_wasm="$gaianet_base_dir/llama-api-server.wasm"
    if [ ! -f "$llamaedge_wasm" ]; then
        printf "LlamaEdge wasm not found at $llamaedge_wasm\n"
        exit 1
    fi

    # parse collection name
    cd $gaianet_base_dir
    cmd="wasmedge --dir .:. \
    --nn-preload default:GGML:AUTO:$chat_model_name \
    --nn-preload embedding:GGML:AUTO:$embedding_model_name \
    llama-api-server.wasm -p $prompt_type \
    --model-name $chat_model_stem,$embedding_model_stem \
    --ctx-size 4096,$embedding_ctx_size \
    --qdrant-url http://127.0.0.1:6333 \
    --qdrant-collection-name "paris" \
    --qdrant-limit 3 \
    --qdrant-score-threshold 0.4 \
    --web-ui ./dashboard \
    --log-prompts \
    --log-stat"

    # Add reverse prompt if it exists
    if [ -n "$reverse_prompt" ]; then
        cmd="$cmd --reverse-prompt \"${reverse_prompt}\""
    fi

    # printf "    Run the following command to start the LlamaEdge API Server:\n\n"
    # printf "    %s\n\n" "$cmd"

    nohup $cmd > start-log.txt 2>&1 &
    sleep 2
    llamaedge_pid=$!
    echo $llamaedge_pid > $gaianet_base_dir/llamaedge.pid

    # (1) download the document
    printf "    * Downloading the document ...\n\n"
    cd $gaianet_base_dir
    doc_filename=$(basename $url_document)
    curl -s $url_document -o $doc_filename

    if [[ $doc_filename != *.txt ]]; then
        printf "Error: the document to upload should be a '*.txt' file\n"

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

        exit 1
    fi


    # (2) upload the document to api-server via the `/v1/files` endpoint
    printf "    * Uploading the document to LlamaEdge API Server ...\n\n"
    doc_response=$(curl -X POST http://127.0.0.1:8080/v1/files -F "file=@$doc_filename")
    id=$(echo "$doc_response" | grep -o '"id":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    filename=$(echo "$doc_response" | grep -o '"filename":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    printf "\n"

    # (3) chunk the document
    printf "    * Chunking the document ...\n\n"
    chunk_response=$(curl -X POST http://127.0.0.1:8080/v1/chunks -H "accept: application/json" -H "Content-Type: application/json" -d "{\"id\":\"$id\",\"filename\":\"$filename\"}")
    chunks=$(echo "$chunk_response" | jq -c '.chunks')

    printf "\n"

    # (4) compute the embeddings for the chunks and upload them to the Qdrant instance
    printf "    * Computing the embeddings and uploading them to the Qdrant instance ...\n\n"

    data=$(jq -n --arg model "all-MiniLM-L6-v2-ggml-model-f16" --argjson input "$chunks" '{"model": $model, "input": $input}')
    embedding_response=$(curl -X POST http://127.0.0.1:8080/v1/embeddings -H "accept: application/json" -H "Content-Type: application/json" -d "$data")

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

# Check if the directory exists, if not, create it
if [ ! -d "$gaianet_base_dir/frp" ]; then
    mkdir -p $gaianet_base_dir/frp
fi

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
        curl -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz
        tar -xzf gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz
        tar -xzf gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz
    fi
    if ! echo $PATH | grep -q "$HOME/gaianet/bin"; then
        echo 'export PATH=$PATH:'$gaianet_base_dir'/bin' >> $HOME/.bashrc
    fi

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # download gaianet-domain statically linked binary
    if [ "$target" = "x86_64" ]; then
        curl -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz
        tar -xzf gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm frp_${gaianet_domain_version}_linux_amd64.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz
        tar -xzf gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm frp_${gaianet_domain_version}_linux_arm64.tar.gz
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

# Copy frpc from $gaianet_base_dir/gaianet-domain to $gaianet_base_dir/bin
cp $gaianet_base_dir/gaianet-domain/frpc $gaianet_base_dir/bin/

# 11. Download frpc.toml, generate a subdomain and print it
curl -L https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/demo/frpc.toml -o $gaianet_base_dir/gaianet-domain/frpc.toml

# Generate a random subdomain
subdomain=$(openssl rand -hex 4)
# Check if the subdomain was generated correctly
if [ -z "$subdomain" ]; then
    echo "Failed to generate a subdomain."
    exit 1
fi

sed -i '' "s/subdomain = \".*\"/subdomain = \"$subdomain\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml

# Read domain from config.json
gaianet_domain=$(awk -F'"' '/"domain":/ {print $4}' $gaianet_base_dir/config.json)

# Resolve the IP address of the domain
ip_address=$(dig +short a.$gaianet_domain | tr -d '\n')

# Check if the IP address was resolved correctly
if [ -z "$ip_address" ]; then
    echo "Failed to resolve the IP address of the domain."
    exit 1
fi

# Replace the serverAddr in frpc.toml
sed -i '' "s/serverAddr = \".*\"/serverAddr = \"$ip_address\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml

# Copy frpc.toml to dashboard/
cp $gaianet_base_dir/gaianet-domain/frpc.toml $gaianet_base_dir/dashboard/

printf "The subdomain for frpc is: http://$subdomain.$gaianet_domain:8080\n"

printf "\n>>> Run 'source $HOME/.bashrc' to get the gaia environment ready. To start the gaia services, run the command: ./start.sh <<<\n"

exit 0
