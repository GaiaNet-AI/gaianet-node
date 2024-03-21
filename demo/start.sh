# !/bin/bash


# represents the directory where the script is located
script_dir=$(pwd)

# Check if "gaianet" directory exists in $HOME
if [ ! -d "$HOME/gaianet" ]; then
    printf "Not found $HOME/gaianet\n"
    exit 1
fi
# Set "gaianet_base_dir" to $HOME/gaianet
gaianet_base_dir="$HOME/gaianet"

# check if config.json exists or not
if [ ! -f "$gaianet_base_dir/config.json" ]; then
    printf "config.json file not found in $gaianet_base_dir\n"
    exit 1
fi

# 1. start a Qdrant instance
printf "[+] Starting Qdrant instance ...\n"

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
    echo $qdrant_pid > $script_dir/qdrant.pid
    printf "\n    Qdrant instance started with pid: $qdrant_pid\n\n"
else
    printf "Qdrant binary not found at $qdrant_executable\n"
    exit 1
fi
printf "\n"

# 2. start a LlamaEdge instance
printf "[+] Starting LlamaEdge API Server ...\n\n"

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

if [[ $url_chat_model =~ ^https://huggingface\.co/second-state ]]; then
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
    printf "Error: the chat model is not from https://huggingface.co/second-state\n"
    exit 1
fi

# parse cli options for embedding model
cd $gaianet_base_dir
url_embedding_model=$(awk -F'"' '/"embedding":/ {print $4}' config.json)
if [[ $url_embedding_model =~ ^https://huggingface\.co/second-state ]]; then
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
    printf "Error: the embedding model is not from https://huggingface.co/second-state\n"
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


printf "    Run the following command to start the LlamaEdge API Server:\n\n"
printf "    %s\n\n" "$cmd"

# eval $cmd

nohup $cmd > start-log.txt 2>&1 &
sleep 2
llamaedge_pid=$!
echo $llamaedge_pid > $script_dir/llamaedge.pid
printf "\n    LlamaEdge API Server started with pid: $llamaedge_pid\n"

# start frpc
printf "[+] Starting frpc ...\n"
nohup $gaianet_base_dir/bin/frpc -c $gaianet_base_dir/frp/frpc.toml > init-log.txt 2>&1 &
sleep 2
frpc_pid=$!
echo $frpc_pid > $script_dir/frpc.pid

# Extract the subdomain from frpc.toml
subdomain=$(grep "subdomain" $gaianet_base_dir/frp/frpc.toml | cut -d'=' -f2 | tr -d ' "')
printf "The subdomain for frpc is: http://$subdomain.gaianet.xyz:8080\n"

printf "\n>>> To stop Qdrant instance and LlamaEdge API Server, run the command: ./stop.sh <<<\n"

exit 0
