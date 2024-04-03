#!/bin/bash


# represents the directory where the script is located
script_dir=$(pwd)

# Check if "gaianet" directory exists in $HOME
if [ ! -d "$HOME/gaianet" ]; then
    printf "Not found $HOME/gaianet\n"
    exit 1
fi
# Set "gaianet_base_dir" to $HOME/gaianet
gaianet_base_dir="$HOME/gaianet"

# check if `log` directory exists or not
if [ ! -d "$gaianet_base_dir/log" ]; then
    mkdir -p $gaianet_base_dir/log
fi
log_dir=$gaianet_base_dir/log

# check if config.json exists or not
if [ ! -f "$gaianet_base_dir/config.json" ]; then
    printf "config.json file not found in $gaianet_base_dir\n"
    exit 1
fi

# 1. start a Qdrant instance
printf "[+] Starting Qdrant instance ...\n"

if [ "$(uname)" == "Darwin" ] || [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    if lsof -Pi :6333 -sTCP:LISTEN -t >/dev/null ; then
        printf "    Port 6333 is in use. Stopping the process on 6333 ...\n\n"
        pid=$(lsof -t -i:6333)
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
    nohup $qdrant_executable > $log_dir/start-qdrant.log 2>&1 &
    sleep 2
    qdrant_pid=$!
    echo $qdrant_pid > $gaianet_base_dir/qdrant.pid
    printf "\n    Qdrant instance started with pid: $qdrant_pid\n\n"
else
    printf "Qdrant binary not found at $qdrant_executable\n\n"
    exit 1
fi

# 2. start a LlamaEdge instance
printf "[+] Starting LlamaEdge API Server ...\n\n"

# We will make sure that the path is setup in case the user runs start.sh immediately after init.sh
source $HOME/.wasmedge/env

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

if [ "$(uname)" == "Darwin" ] || [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    if lsof -Pi :$llamaedge_port -sTCP:LISTEN -t >/dev/null ; then
        printf "    Port $llamaedge_port is in use. Stopping the process on $llamaedge_port ...\n\n"
        pid=$(lsof -t -i:$llamaedge_port)
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
cmd="wasmedge --dir .:./dashboard \
  --nn-preload default:GGML:AUTO:$chat_model_name \
  --nn-preload embedding:GGML:AUTO:$embedding_model_name \
  llama-api-server.wasm -p $prompt_type \
  --model-name $chat_model_stem,$embedding_model_stem \
  --ctx-size $chat_ctx_size,$embedding_ctx_size \
  --qdrant-url http://127.0.0.1:6333 \
  --qdrant-collection-name "default" \
  --qdrant-limit 3 \
  --qdrant-score-threshold 0.4 \
  --web-ui ./ \
  --socket-addr 0.0.0.0:$llamaedge_port \
  --log-prompts \
  --log-stat"

# Add reverse prompt if it exists
if [ -n "$reverse_prompt" ]; then
    cmd="$cmd --reverse-prompt \"${reverse_prompt}\""
fi


printf "    Run the following command to start the LlamaEdge API Server:\n\n"
printf "    %s\n\n" "$cmd"

# eval $cmd

nohup $cmd > $log_dir/start-llamaedge.log 2>&1 &
sleep 2
llamaedge_pid=$!
echo $llamaedge_pid > $gaianet_base_dir/llamaedge.pid
printf "\n    LlamaEdge API Server started with pid: $llamaedge_pid\n\n"

# start gaianet-domain
printf "[+] Starting gaianet-domain ...\n"
nohup $gaianet_base_dir/bin/frpc -c $gaianet_base_dir/gaianet-domain/frpc.toml > $log_dir/start-gaianet-domain.log 2>&1 &
sleep 2
gaianet_domain_pid=$!
echo $gaianet_domain_pid > $gaianet_base_dir/gaianet-domain.pid
printf "\n    gaianet-domain started with pid: $gaianet_domain_pid\n\n"

# Extract the subdomain from frpc.toml
subdomain=$(grep "subdomain" $gaianet_base_dir/gaianet-domain/frpc.toml | cut -d'=' -f2 | tr -d ' "')
printf "    The subdomain for gaianet-domain is: https://$subdomain.gaianet.xyz\n"

printf "\n>>> To stop Qdrant instance and LlamaEdge API Server, run the command: ./stop.sh <<<\n"

exit 0
