#!/bin/bash

# target name
target=$(uname -m)

# represents the directory where the script is located
cwd=$(pwd)

# 0: do not reinstall, 1: reinstall
reinstall=0
# url to the config file
config_url=""
# path to the gaianet base directory
gaianet_base_dir="$HOME/gaianet"
# qdrant binary
qdrant_version="v1.8.4"


function print_usage {
    printf "Usage:\n"
    printf "  ./install.sh [Options]\n\n"
    printf "Options:\n"
    printf "  --config <Url>: specify a url to the config file\n"
    printf "  --base <Path>: specify a path to the gaianet base directory\n"
    printf "  --reinstall: install and download all required deps\n"
    printf "  --help: Print usage\n"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --config)
            config_url="$2"
            shift
            shift
            ;;
        --base)
            gaianet_base_dir="$2"
            shift
            shift
            ;;
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


# if need to reinstall, remove the $gaianet_base_dir directory
if [ "$reinstall" -eq 1 ] && [ -d "$gaianet_base_dir" ]; then
    printf "[+] Removing the existing $gaianet_base_dir directory ...\n\n"
    rm -rf $gaianet_base_dir
fi

# Check if $gaianet_base_dir directory exists
if [ ! -d $gaianet_base_dir ]; then
    mkdir -p $gaianet_base_dir
fi

# check if `log` directory exists or not
if [ ! -d "$gaianet_base_dir/log" ]; then
    mkdir -p $gaianet_base_dir/log
fi
log_dir=$gaianet_base_dir/log

# 1. Download default `config.json`
cd $gaianet_base_dir
if [ ! -f "$gaianet_base_dir/config.json" ]; then
    printf "[+] Downloading default config file ...\n"
    curl -s -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/config.json
    printf "\n"
fi

# 2. download nodeid.json
if [ ! -f "$gaianet_base_dir/nodeid.json" ]; then
    printf "[+] Downloading nodeid.json ...\n"
    curl -s -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/nodeid.json
    printf "\n"
fi

# 3. Install WasmEdge and ggml plugin
if ! command -v wasmedge >/dev/null 2>&1 || [ "$reinstall" -eq 1 ]; then
    printf "[+] Installing WasmEdge with wasi-nn_ggml plugin ...\n\n"
    if curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install_v2.sh | bash -s; then
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

# 4. Install Qdrant binary and prepare directories
# Check if "$gaianet_base_dir/bin" directory exists
if [ ! -d "$gaianet_base_dir/bin" ]; then
    # If not, create it
    mkdir -p $gaianet_base_dir/bin
fi
# 4.1 Inatall Qdrant binary
if [ ! -f "$gaianet_base_dir/bin/qdrant" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Installing Qdrant binary...\n"

    printf "    * Download Qdrant binary\n"
    if [ "$(uname)" == "Darwin" ]; then
        # download qdrant binary
        if [ "$target" = "x86_64" ]; then
            curl --retry 3 --progress-bar -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-apple-darwin.tar.gz
            tar -xzf qdrant-x86_64-apple-darwin.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-x86_64-apple-darwin.tar.gz
        elif [ "$target" = "arm64" ]; then
            curl --retry 3 --progress-bar -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-apple-darwin.tar.gz
            tar -xzf qdrant-aarch64-apple-darwin.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-aarch64-apple-darwin.tar.gz
        fi

    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # download qdrant statically linked binary
        if [ "$target" = "x86_64" ]; then
            curl --retry 3 --progress-bar -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-unknown-linux-musl.tar.gz
            tar -xzf qdrant-x86_64-unknown-linux-musl.tar.gz -C $gaianet_base_dir/bin
            rm qdrant-x86_64-unknown-linux-musl.tar.gz
        elif [ "$target" = "aarch64" ]; then
            curl --retry 3 --progress-bar -LO https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-unknown-linux-musl.tar.gz
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

# 4.2 Init qdrant directory
if [ ! -d "$gaianet_base_dir/qdrant" ]; then
    printf "    * Initialize Qdrant directory\n"
    mkdir -p $gaianet_base_dir/qdrant && cd $gaianet_base_dir/qdrant

    # download qdrant binary
    curl --retry 3 -s -LO https://github.com/qdrant/qdrant/archive/refs/tags/$qdrant_version.tar.gz

    mkdir "$qdrant_version"
    tar -xzf "$qdrant_version.tar.gz" -C "$qdrant_version" --strip-components 1
    rm $qdrant_version.tar.gz

    cp -r $qdrant_version/config .
    rm -rf $qdrant_version

    printf "\n"
fi

# 5. Download rag-api-server.wasm
cd $gaianet_base_dir
if [ ! -f "$gaianet_base_dir/rag-api-server.wasm" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading the rag-api-server.wasm ...\n"
    curl --retry 3 --progress-bar -LO https://github.com/LlamaEdge/rag-api-server/releases/latest/download/rag-api-server.wasm
else
    printf "[+] Using the cached rag-api-server.wasm ...\n"
fi
printf "\n"

# 6. Download dashboard to $gaianet_base_dir
if ! command -v tar &> /dev/null; then
    echo "tar could not be found, please install it."
    exit 1
fi
if [ ! -d "$gaianet_base_dir/dashboard" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading dashboard ...\n"
    if [ -d "$gaianet_base_dir/gaianet-node" ]; then
        rm -rf $gaianet_base_dir/gaianet-node
    fi
    cd $gaianet_base_dir
    curl --retry 3 --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/dashboard.tar.gz
    tar xzf dashboard.tar.gz

    rm -rf $gaianet_base_dir/dashboard.tar.gz
else
    printf "[+] Using cached dashboard ...\n"
fi
printf "\n"

# 7. Generate node ID and copy config to dashboard
if [ ! -f "$gaianet_base_dir/registry.wasm" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading the registry.wasm ...\n\n"
    curl -s -LO https://github.com/GaiaNet-AI/gaianet-node/raw/main/utils/registry/registry.wasm
else
    printf "[+] Using cached registry ...\n\n"
fi
printf "[+] Generating node ID ...\n"
wasmedge --dir .:. registry.wasm
printf "\n"

# 8. Install gaianet-domain
printf "[+] Installing gaianet-domain...\n"
# Check if the directory exists, if not, create it
if [ ! -d "$gaianet_base_dir/gaianet-domain" ]; then
    mkdir -p $gaianet_base_dir/gaianet-domain
fi

gaianet_domain_version="v0.1.0-alpha.1"
if [ "$(uname)" == "Darwin" ]; then
    # download gaianet-domain binary
    if [ "$target" = "x86_64" ]; then
        curl --retry 3 --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz
        tar -xzf gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl --retry 3 --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz
        tar -xzf gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz
    fi

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # download gaianet-domain statically linked binary
    if [ "$target" = "x86_64" ]; then
        curl --retry 3 --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz
        tar --warning=no-unknown-keyword -xzf gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz
    elif [ "$target" = "arm64" ]; then
        curl --retry 3 --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz
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

# 12. Download frpc.toml, generate a subdomain and print it
curl -s -L https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/frpc.toml -o $gaianet_base_dir/gaianet-domain/frpc.toml

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

# Generate a random string as Device ID
device_id="device-$(openssl rand -hex 12)"

$sed_i_cmd "s/subdomain = \".*\"/subdomain = \"$subdomain\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
$sed_i_cmd "s/serverAddr = \".*\"/serverAddr = \"$ip_address\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
$sed_i_cmd "s/name = \".*\"/name = \"$subdomain.$gaianet_domain\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
$sed_i_cmd "s/metadatas.deviceId = \".*\"/metadatas.deviceId = \"$device_id\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml

# Remove all files in the directory except for frpc and frpc.toml
find $gaianet_base_dir/gaianet-domain -type f -not -name 'frpc' -not -name 'frpc.toml' -exec rm -f {} \;

printf "Your node ID is $subdomain Please register it in your portal account to receive awards!\n"

exit 0

# # 7. Install gaianet-domain at $HOME/gaianet/bin
# printf "[+] Installing gaianet-domain...\n"
# # Check if the directory exists, if not, create it
# if [ ! -d "$gaianet_base_dir/gaianet-domain" ]; then
#     mkdir -p $gaianet_base_dir/gaianet-domain
# fi

# gaianet_domain_version="v0.1.0-alpha.1"
# if [ "$(uname)" == "Darwin" ]; then
#     # download gaianet-domain binary
#     if [ "$target" = "x86_64" ]; then
#         curl --retry 3 --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz
#         tar -xzf gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
#         rm gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz
#     elif [ "$target" = "arm64" ]; then
#         curl --retry 3 --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz
#         tar -xzf gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
#         rm gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz
#     fi

# elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
#     # download gaianet-domain statically linked binary
#     if [ "$target" = "x86_64" ]; then
#         curl --retry 3 --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz
#         tar --warning=no-unknown-keyword -xzf gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
#         rm gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz
#     elif [ "$target" = "arm64" ]; then
#         curl --retry 3 --progress-bar -LO https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz
#         tar --warning=no-unknown-keyword -xzf gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
#         rm gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz
#     fi

# elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
#     printf "For Windows users, please run this script in WSL.\n"
#     exit 1
# else
#     printf "Only support Linux, MacOS and Windows.\n"
#     exit 1
# fi
# printf "\n"

# # Copy frpc from $gaianet_base_dir/gaianet-domain to $gaianet_base_dir/bin
# cp $gaianet_base_dir/gaianet-domain/frpc $gaianet_base_dir/bin/

# # 8. Download frpc.toml, generate a subdomain and print it
# curl -s -L https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/frpc.toml -o $gaianet_base_dir/gaianet-domain/frpc.toml

# # Read address from config.json as node subdomain
# subdomain=$(awk -F'"' '/"address":/ {print $4}' $gaianet_base_dir/config.json)

# # Check if the subdomain was read correctly
# if [ -z "$subdomain" ]; then
#     echo "Failed to read the address from config.json."
#     exit 1
# fi

# # Read domain from config.json
# gaianet_domain=$(awk -F'"' '/"domain":/ {print $4}' $gaianet_base_dir/config.json)

# # Resolve the IP address of the domain
# ip_address=$(dig +short a.$gaianet_domain | tr -d '\n')

# # Check if the IP address was resolved correctly
# if [ -z "$ip_address" ]; then
#     echo "Failed to resolve the IP address of the domain."
#     exit 1
# fi

# # Replace the serverAddr & subdomain in frpc.toml
# if [[ "$OSTYPE" == "linux-gnu"* ]]; then
#     sed_i_cmd="sed -i"
# elif [[ "$OSTYPE" == "darwin"* ]]; then
#     sed_i_cmd="sed -i ''"
# else
#     echo "Unsupported OS"
#     exit 1
# fi

# # 9. Generate a random string as Device ID
# device_id="device-$(openssl rand -hex 12)"

# $sed_i_cmd "s/subdomain = \".*\"/subdomain = \"$subdomain\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
# $sed_i_cmd "s/serverAddr = \".*\"/serverAddr = \"$ip_address\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
# $sed_i_cmd "s/name = \".*\"/name = \"$subdomain.$gaianet_domain\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
# $sed_i_cmd "s/metadatas.deviceId = \".*\"/metadatas.deviceId = \"$device_id\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml

# # Remove all files in the directory except for frpc and frpc.toml
# find $gaianet_base_dir/gaianet-domain -type f -not -name 'frpc' -not -name 'frpc.toml' -exec rm -f {} \;

# printf "Please run the start.sh script to start the GaiaNet node. Once started, the node will be available at: https://$subdomain.$gaianet_domain\n"

# printf "Your node ID is $subdomain Please register it in your portal account to receive awards!\n"

exit 0
