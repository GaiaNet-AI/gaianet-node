#!/bin/bash

set -e

# target name
target=$(uname -m)

# represents the directory where the script is located
cwd=$(pwd)

repo_branch="main"

# 0: do not reinstall, 1: reinstall
reinstall=0
# 0: must be root or sudo, 1: regular unprivileged user
unprivileged=0
# url to the config file
config_url=""
# path to the gaianet base directory
gaianet_base_dir="$HOME/gaianet"
# qdrant binary
qdrant_version="v1.9.0"

# print in red color
RED=$'\e[0;31m'
# print in green color
GREEN=$'\e[0;32m'
# print in yellow color
YELLOW=$'\e[0;33m'
# No Color
NC=$'\e[0m'

function print_usage {
    printf "Usage:\n"
    printf "  ./install.sh [Options]\n\n"
    printf "Options:\n"
    printf "  --config <Url>: specify a url to the config file\n"
    printf "  --base <Path>: specify a path to the gaianet base directory\n"
    printf "  --reinstall: install and download all required deps\n"
    printf "  --unprivileged: install the gaianet CLI tool into base directory instead of system directory\n"
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
        --unprivileged)
            unprivileged=1
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

info() {
    printf "${GREEN}$1${NC}\n\n"
}

error() {
    printf "${RED}$1${NC}\n\n"
}

warning() {
    printf "${YELLOW}$1${NC}\n\n"
}

# download target file to destination. If failed, then exit
check_curl() {
    curl --retry 3 --progress-bar -L "$1" -o "$2"

    if [ $? -ne 0 ]; then
        error "    * Failed to download $1"
        exit 1
    fi
}

check_curl_silent() {
    curl --retry 3 -s --progress-bar -L "$1" -o "$2"

    if [ $? -ne 0 ]; then
        error "    * Failed to download $1"
        exit 1
    fi
}

printf "\n"
cat <<EOF
 ██████╗  █████╗ ██╗ █████╗ ███╗   ██╗███████╗████████╗
██╔════╝ ██╔══██╗██║██╔══██╗████╗  ██║██╔════╝╚══██╔══╝
██║  ███╗███████║██║███████║██╔██╗ ██║█████╗     ██║
██║   ██║██╔══██║██║██╔══██║██║╚██╗██║██╔══╝     ██║
╚██████╔╝██║  ██║██║██║  ██║██║ ╚████║███████╗   ██║
 ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝
EOF

printf "\n\n"

# if need to reinstall, remove the $gaianet_base_dir directory
if [ "$reinstall" -eq 1 ] && [ -d "$gaianet_base_dir" ]; then
    printf "[+] Removing the existing $gaianet_base_dir directory ...\n\n"
    rm -rf $gaianet_base_dir
fi

# Check if $gaianet_base_dir directory exists
if [ ! -d $gaianet_base_dir ]; then
    mkdir -p -m777 $gaianet_base_dir
fi
cd $gaianet_base_dir

# check if `log` directory exists or not. It needs to allow `gaianet` to write into it
if [ ! -d "$gaianet_base_dir/log" ]; then
    mkdir -p -m777 $gaianet_base_dir/log
fi
log_dir=$gaianet_base_dir/log

# 1. Install `gaianet` CLI tool.
if [ "$unprivileged" -eq 0 ]; then
    for BINDIR in /usr/local/bin /usr/bin; do
        echo $PATH | grep -q $BINDIR && break || continue
    done
    # Check if the script is running as root. If not, it checks if `sudo` is available.
    # If `sudo` is available, it sets the `SUDO` variable to "sudo". If `sudo` is not available, it prints an error message and exists.
    SUDO=
    if [ "$(id -u)" -ne 0 ]; then
        # check if a command is available on the system
        if ! command -v sudo >/dev/null; then
            printf "[ERROR] This script requires superuser permissions. Please re-run as root or make sure that you can sudo.\n"
        fi

        SUDO="sudo"
    fi
    # create the directory specified by $BINDIR with root ownership and 755 permissions. The first thing the script asks is the sudo password.
    $SUDO install -o0 -g0 -m755 -d $BINDIR

    printf "[+] Installing gaianet CLI tool ...\n"
    check_curl https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/$repo_branch/gaianet $gaianet_base_dir/gaianet

    # copy the `gaianet` file to $BINDIR with root ownership and 755 permissions.
    $SUDO install -o0 -g0 -m755 $gaianet_base_dir/gaianet $BINDIR/gaianet
    # remove the downloaded `gaianet` file
    rm $gaianet_base_dir/gaianet
    info "    * gaianet CLI tool is installed in $BINDIR/gaianet"
else
    printf "[+] Installing gaianet CLI tool ...\n"
    check_curl https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/$repo_branch/gaianet $gaianet_base_dir/gaianet
    chmod +x ./gaianet
    info "    * gaianet CLI tool is installed in $gaianet_base_dir/gaianet"
fi

# 2. Download default `config.json`
printf "[+] Downloading default config file ...\n"
if [ ! -f "$gaianet_base_dir/config.json" ]; then
    check_curl https://github.com/GaiaNet-AI/gaianet-node/raw/main/config.json $gaianet_base_dir/config.json

    info "    * The default config file is downloaded in $gaianet_base_dir"
else
    warning "    * Use the cached config file in $gaianet_base_dir"
fi

# 3. download nodeid.json
if [ ! -f "$gaianet_base_dir/nodeid.json" ]; then
    printf "[+] Downloading nodeid.json ...\n"
    check_curl https://github.com/GaiaNet-AI/gaianet-node/raw/main/nodeid.json $gaianet_base_dir/nodeid.json

    info "    * The nodeid.json is downloaded in $gaianet_base_dir"
fi

# 4. Install WasmEdge and ggml plugin
printf "[+] Installing WasmEdge with wasi-nn_ggml plugin ...\n"
if curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install_v2.sh | bash -s; then
    source $HOME/.wasmedge/env
    wasmedge_path=$(which wasmedge)
    wasmedge_version=$(wasmedge --version)
    info "    * The $wasmedge_version is installed in $wasmedge_path."
else
    error "    * Failed to install WasmEdge"
    exit 1
fi

# 5. Install Qdrant binary and prepare directories
# Check if "$gaianet_base_dir/bin" directory exists
if [ ! -d "$gaianet_base_dir/bin" ]; then
    # If not, create it
    mkdir -p -m777 $gaianet_base_dir/bin
fi
# 5.1 Inatall Qdrant binary
printf "[+] Installing Qdrant binary...\n"
if [ ! -f "$gaianet_base_dir/bin/qdrant" ] || [ "$reinstall" -eq 1 ]; then
    printf "    * Download Qdrant binary\n"
    if [ "$(uname)" == "Darwin" ]; then
        # download qdrant binary
        if [ "$target" = "x86_64" ]; then
            check_curl https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-apple-darwin.tar.gz $gaianet_base_dir/qdrant-x86_64-apple-darwin.tar.gz

            tar -xzf $gaianet_base_dir/qdrant-x86_64-apple-darwin.tar.gz -C $gaianet_base_dir/bin
            rm $gaianet_base_dir/qdrant-x86_64-apple-darwin.tar.gz

            info "      The Qdrant binary is downloaded in $gaianet_base_dir/bin"

        elif [ "$target" = "arm64" ]; then
            check_curl https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-apple-darwin.tar.gz $gaianet_base_dir/qdrant-aarch64-apple-darwin.tar.gz

            tar -xzf $gaianet_base_dir/qdrant-aarch64-apple-darwin.tar.gz -C $gaianet_base_dir/bin
            rm $gaianet_base_dir/qdrant-aarch64-apple-darwin.tar.gz

            info "      The Qdrant binary is downloaded in $gaianet_base_dir/bin"
        fi

    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # download qdrant statically linked binary
        if [ "$target" = "x86_64" ]; then
            check_curl https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-unknown-linux-musl.tar.gz $gaianet_base_dir/qdrant-x86_64-unknown-linux-musl.tar.gz

            tar -xzf $gaianet_base_dir/qdrant-x86_64-unknown-linux-musl.tar.gz -C $gaianet_base_dir/bin
            rm $gaianet_base_dir/qdrant-x86_64-unknown-linux-musl.tar.gz

            info "      The Qdrant binary is downloaded in $gaianet_base_dir/bin"

        elif [ "$target" = "aarch64" ]; then
            check_curl https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-unknown-linux-musl.tar.gz $gaianet_base_dir/qdrant-aarch64-unknown-linux-musl.tar.gz

            tar -xzf $gaianet_base_dir/qdrant-aarch64-unknown-linux-musl.tar.gz -C $gaianet_base_dir/bin
            rm $gaianet_base_dir/qdrant-aarch64-unknown-linux-musl.tar.gz

            info "      The Qdrant binary is downloaded in $gaianet_base_dir/bin"
        fi

    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        error "    * For Windows users, please run this script in WSL."
        exit 1
    else
        error "    * Only support Linux, MacOS and Windows."
        exit 1
    fi

else
    warning "    * Use the cached Qdrant binary in $gaianet_base_dir/bin"
fi

# 5.2 Init qdrant directory
if [ ! -d "$gaianet_base_dir/qdrant" ]; then
    printf "    * Initialize Qdrant directory\n"
    mkdir -p -m777 $gaianet_base_dir/qdrant && cd $gaianet_base_dir/qdrant

    # download qdrant binary
    check_curl_silent https://github.com/qdrant/qdrant/archive/refs/tags/$qdrant_version.tar.gz $gaianet_base_dir/qdrant/$qdrant_version.tar.gz

    mkdir -p "$qdrant_version"
    tar -xzf "$gaianet_base_dir/qdrant/$qdrant_version.tar.gz" -C "$qdrant_version" --strip-components 1
    rm $gaianet_base_dir/qdrant/$qdrant_version.tar.gz

    cp -r $qdrant_version/config .
    rm -rf $qdrant_version

    printf "\n"

    # disable telemetry in the `config.yaml` file
    printf "    * Disable telemetry\n"
    config_file="$gaianet_base_dir/qdrant/config/config.yaml"

    if [ -f "$config_file" ]; then
        if [ "$(uname)" == "Darwin" ]; then
            sed -i '' 's/telemetry_disabled: false/telemetry_disabled: true/' "$config_file"
        elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
            sed -i 's/telemetry_disabled: false/telemetry_disabled: true/' "$config_file"
        elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
            error "For Windows users, please run this script in WSL."
            exit 1
        else
            error "Only support Linux, MacOS and Windows(WSL)."
            exit 1
        fi
    fi

    printf "\n"
fi

# 6. Download rag-api-server.wasm
printf "[+] Downloading LlamaEdge API server ...\n"
check_curl https://github.com/LlamaEdge/rag-api-server/releases/latest/download/rag-api-server.wasm $gaianet_base_dir/rag-api-server.wasm
check_curl https://github.com/LlamaEdge/LlamaEdge/releases/latest/download/llama-api-server.wasm $gaianet_base_dir/llama-api-server.wasm
info "    * The rag-api-server.wasm and llama-api-server.wasm are downloaded in $gaianet_base_dir"

# 7. Download dashboard to $gaianet_base_dir
if ! command -v tar &> /dev/null; then
    echo "tar could not be found, please install it."
    exit 1
fi
printf "[+] Downloading dashboard ...\n"
if [ ! -d "$gaianet_base_dir/dashboard" ] || [ "$reinstall" -eq 1 ]; then
    if [ -d "$gaianet_base_dir/gaianet-node" ]; then
        rm -rf $gaianet_base_dir/gaianet-node
    fi

    check_curl https://github.com/GaiaNet-AI/gaianet-node/raw/main/dashboard.tar.gz $gaianet_base_dir/dashboard.tar.gz

    tar xzf $gaianet_base_dir/dashboard.tar.gz -C $gaianet_base_dir
    rm -rf $gaianet_base_dir/dashboard.tar.gz

    info "    * The dashboard is downloaded in $gaianet_base_dir"
else
    warning "    * Use the cached dashboard in $gaianet_base_dir"
fi

# 8. Generate node ID and copy config to dashboard
printf "[+] Generating node ID ...\n"
if [ ! -f "$gaianet_base_dir/registry.wasm" ] || [ "$reinstall" -eq 1 ]; then
    printf "    * Download registry.wasm\n"
    check_curl https://github.com/GaiaNet-AI/gaianet-node/raw/main/utils/registry/registry.wasm $gaianet_base_dir/registry.wasm
    info "      The registry.wasm is downloaded in $gaianet_base_dir"
else
    warning "    * Use the cached registry.wasm in $gaianet_base_dir"
fi
printf "    * Generate node ID\n"
cd $gaianet_base_dir
wasmedge --dir .:. registry.wasm
printf "\n"

# 9. Install gaianet-domain
printf "[+] Installing gaianet-domain...\n"
# Check if the directory exists, if not, create it
if [ ! -d "$gaianet_base_dir/gaianet-domain" ]; then
    mkdir -p -m777 $gaianet_base_dir/gaianet-domain
fi
cd $gaianet_base_dir
gaianet_domain_version="v0.1.0-alpha.1"
printf "    * Download gaianet-domain binary\n"
if [ "$(uname)" == "Darwin" ]; then
    if [ "$target" = "x86_64" ]; then
        check_curl https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz

        tar -xzf $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_darwin_amd64.tar.gz

        info "      gaianet-domain is downloaded in $gaianet_base_dir"
    elif [ "$target" = "arm64" ]; then
        check_curl https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz

        tar -xzf $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_darwin_arm64.tar.gz

        info "      gaianet-domain is downloaded in $gaianet_base_dir"
    fi

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # download gaianet-domain statically linked binary
    if [ "$target" = "x86_64" ]; then
        check_curl https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz

        tar --warning=no-unknown-keyword -xzf $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_linux_amd64.tar.gz

        info "      gaianet-domain is downloaded in $gaianet_base_dir"
    elif [ "$target" = "arm64" ]; then
        check_curl https://github.com/GaiaNet-AI/gaianet-domain/releases/download/$gaianet_domain_version/gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz

        tar --warning=no-unknown-keyword -xzf $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaianet-domain
        rm $gaianet_base_dir/gaianet_domain_${gaianet_domain_version}_linux_arm64.tar.gz

        info "      gaianet-domain is downloaded in $gaianet_base_dir"
    fi

elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    error "For Windows users, please run this script in WSL."
    exit 1
else
    error "Only support Linux, MacOS and Windows."
    exit 1
fi

# Copy frpc from $gaianet_base_dir/gaianet-domain to $gaianet_base_dir/bin
printf "    * Install frpc binary\n"
cp $gaianet_base_dir/gaianet-domain/frpc $gaianet_base_dir/bin/
info "      frpc binary is installed in $gaianet_base_dir/bin"

# 10. Download frpc.toml, generate a subdomain and print it
printf "    * Download frpc.toml\n"
check_curl_silent https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/frpc.toml $gaianet_base_dir/gaianet-domain/frpc.toml
info "      frpc.toml is downloaded in $gaianet_base_dir/gaianet-domain"

# Read address from config.json as node subdomain
subdomain=$(awk -F'"' '/"address":/ {print $4}' $gaianet_base_dir/config.json)

# Check if the subdomain was read correctly
if [ -z "$subdomain" ]; then
    error "Failed to read the address from config.json."
    exit 1
fi

# Read domain from config.json
gaianet_domain=$(awk -F'"' '/"domain":/ {print $4}' $gaianet_base_dir/config.json)

# Resolve the IP address of the domain
ip_address=$(dig +short a.$gaianet_domain | tr -d '\n')

# Check if the IP address was resolved correctly
if [ -z "$ip_address" ]; then
    error "Failed to resolve the IP address of the domain."
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

printf "[+] COMPLETED! The gaianet node has been installed successfully.\n\n"

printf "Your node ID is $subdomain. Please register it in your portal account to receive awards!\n\n"

info ">>> Next, you should initialize the GaiaNet node with the LLM and knowledge base. Run the command: gaianet init <<<"

exit 0
