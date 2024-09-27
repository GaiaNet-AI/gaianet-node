#!/bin/bash

set -e

# target name
target=$(uname -m)

# represents the directory where the script is located
cwd=$(pwd)

repo_branch="main"
version="0.4.4"
rag_api_server_version="0.9.6"
llama_api_server_version="0.14.6"
wasmedge_version="0.14.1"
ggml_bn="b3613"
vector_version="0.38.0"
dashboard_version="v3.1"
assistant_version="0.2.3"
qdrant_version="v1.11.4"

# 0: do not reinstall, 1: reinstall
reinstall=0
# 0: do not upgrade, 1: upgrade
upgrade=0
# file path to be backed up
backup_to_file=""
# file path to be migrated from
migrated_from_file=""
# 0: must be root or sudo, 1: regular unprivileged user
unprivileged=0
# url to the config file
config_url=""
# path to the gaianet base directory
gaianet_base_dir="$HOME/gaianet"
# tmp directory
tmp_dir="$gaianet_base_dir/tmp"
# specific CUDA enabled GGML plugin
ggmlcuda=""
# 0: disable vector, 1: enable vector
enable_vector=0

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
    printf "  --config <Url>     Specify a url to the config file\n"
    printf "  --base <Path>      Specify a path to the gaianet base directory\n"
    printf "  --reinstall        Install and download all required deps\n"
    printf "  --upgrade          Upgrade the gaianet node\n"
    printf "  --backup <File>    Backup the config to the specified file\n"
    printf "  --migrate <File>   Install and migrate the config from the specified backup file\n"
    printf "  --tmpdir <Path>    Specify a path to the temporary directory [default: $gaianet_base_dir/tmp]\n"
    printf "  --ggmlcuda [11/12] Install a specific CUDA enabled GGML plugin version [Possible values: 11, 12].\n"
    # printf "  --unprivileged: install the gaianet CLI tool into base directory instead of system directory\n"
    printf "  --enable-vector:   Install vector log aggregator\n"
    printf "  --version          Print version\n"
    printf "  --help             Print usage\n"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --config)
            config_url="$2"
            shift 2
            ;;
        --base)
            gaianet_base_dir="$2"

            if [ ! -n "$gaianet_base_dir" ]; then
                echo "$gaianet_base_dir should be a valid directory"
                exit 1
            fi
            gaianet_base_dir=$(realpath -m "$gaianet_base_dir")
            shift 2
            ;;
        --reinstall)
            reinstall=1
            shift
            ;;
        --upgrade)
            upgrade=1
            shift
            ;;
        --backup)
            backup_to_file="$2"

            if [ ! -n "$backup_to_file" ]; then
                echo "Please specify the backup file"
                exit 1
            fi
            backup_to_file=$(realpath -m "$backup_to_file")
            shift 2
            ;;
        --migrate)
            migrated_from_file="$2"

            if [ ! -f "$migrated_from_file" ]; then
                echo "Cannot find the backup file: $migrated_from_file"
                exit 1
            fi
            migrated_from_file=$(realpath -m "$migrated_from_file")
            shift 2
            ;;
        --tmpdir)
            tmp_dir="$2"
            shift 2
            ;;
        --ggmlcuda)
            ggmlcuda="$2"
            shift 2
            ;;
        # --unprivileged)
        #     unprivileged=1
        #     shift
        #     ;;
        --enable-vector)
            enable_vector=1
            shift
            ;;
        --version)
            echo "Gaianet-node Installer v$version"
            exit 0
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

sed_in_place() {
    if [ "$(uname)" == "Darwin" ]; then
        sed -i '' "$@"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        sed -i "$@"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        error "    * For Windows users, please run this script in WSL."
        exit 1
    else
        error "    * Only support Linux, MacOS and Windows."
        exit 1
    fi
}

# Upgrade and migrate cannot coexist
if [ "$upgrade" -eq 1 ] && [ -n "$migrated_from_file" ]; then
    error "    Cannot use both --upgrade and --migrate"
    exit 1
fi

# Do backup
if [ -n "$backup_to_file" ]; then
    if [ ! -d $gaianet_base_dir ]; then
        error "    Cannot backup because the directory $gaianet_base_dir does not exist"
        exit 1
    fi

    backup_keystore_filename=$(grep '"keystore":' $gaianet_base_dir/nodeid.json | awk -F'"' '{print $4}')
    cd $gaianet_base_dir
    if [ -f gaia-frp/frpc.toml ]; then
        tar -cf $backup_to_file config.json nodeid.json gaia-frp/frpc.toml $backup_keystore_filename
    else
        tar -cf $backup_to_file config.json nodeid.json gaianet-domain/frpc.toml $backup_keystore_filename
    fi
    info "Config from $gaianet_base_dir has been backed up to $backup_to_file."
    info "Pass it as the value of '--migrate' option to install your new GaiaNet node"
    exit 0
fi


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

# If need to upgrade, remove the all existing files and subdirectories in the base directory, except for the backup subdirectory and its contents
# If need to reinstall, remove the $gaianet_base_dir directory
if [ -d "$gaianet_base_dir" ]; then
    if [ "$upgrade" -eq 1 ]; then

        # check version
        if ! command -v gaianet &> /dev/null; then
            current_version=""
        else
            current_version=$(gaianet --version)
        fi

        if [ -n "$current_version" ] && [ "GaiaNet CLI Tool v$version" = "$current_version" ]; then
            info "The current version ($current_version) is the same as the target version (GaiaNet CLI Tool v$version). Skip the upgrade process."
            exit 0

        else
            info "The gaianet node will be upgraded to v$version."
        fi

        printf "[+] Performing backup before upgrading to v$version ...\n\n"

        if [ ! -d "$gaianet_base_dir/backup" ]; then
            printf "    * Create $gaianet_base_dir/backup\n"
            mkdir -p "$gaianet_base_dir/backup"
        fi

        # backup keystore file
        keystore_filename=$(grep '"keystore":' $gaianet_base_dir/nodeid.json | awk -F'"' '{print $4}')
        if [ -z "$keystore_filename" ]; then
            error "Failed to read the 'keystore' field from $gaianet_base_dir/nodeid.json."
            exit 1
        else
            if [ -f "$gaianet_base_dir/$keystore_filename" ]; then
                printf "    * Copy $keystore_filename to $gaianet_base_dir/backup/\n"
                cp $gaianet_base_dir/$keystore_filename $gaianet_base_dir/backup/
            else
                error "Failed to copy the keystore file. Reason: the keystore file does not exist in $gaianet_base_dir."
                exit 1
            fi
        fi
        # backup config.json
        if [ -f "$gaianet_base_dir/config.json" ]; then
            printf "    * Copy config.json to $gaianet_base_dir/backup/\n"
            cp $gaianet_base_dir/config.json $gaianet_base_dir/backup/
        else
            error "Failed to copy the config.json. Reason: the config.json does not exist in $gaianet_base_dir."
            exit 1
        fi
        # backup nodeid.json
        if [ -f "$gaianet_base_dir/nodeid.json" ]; then
            printf "    * Copy nodeid.json to $gaianet_base_dir/backup/\n"
            cp $gaianet_base_dir/nodeid.json $gaianet_base_dir/backup/
        else
            error "Failed to copy the nodeid.json. Reason: the nodeid.json does not exist in $gaianet_base_dir."
            exit 1
        fi
        # backup frpc.toml
        if [ -f "$gaianet_base_dir/gaia-frp/frpc.toml" ]; then
            printf "    * Copy frpc.toml to $gaianet_base_dir/backup/\n"
            cp $gaianet_base_dir/gaia-frp/frpc.toml $gaianet_base_dir/backup/
        elif [ -f "$gaianet_base_dir/gaianet-domain/frpc.toml" ]; then
            printf "    * Copy frpc.toml to $gaianet_base_dir/backup/\n"
            cp $gaianet_base_dir/gaianet-domain/frpc.toml $gaianet_base_dir/backup/
        else
            error "Failed to copy the frpc.toml. Reason: the frpc.toml does not exist in $gaianet_base_dir/gaia-frp."
            exit 1
        fi
        # backup deviceid.txt
        if [ -f "$gaianet_base_dir/deviceid.txt" ]; then
            printf "    * Copy deviceid.txt to $gaianet_base_dir/backup/\n"
            cp $gaianet_base_dir/deviceid.txt $gaianet_base_dir/backup/
        else
            warning "    * The deviceid.txt does not exist in $gaianet_base_dir."
        fi

        # remove the all existing files and subdirectories in the base directory, except for the backup subdirectory and its contents
        find "$gaianet_base_dir" -mindepth 1 -not -name 'backup' -not -path '*/backup/*' -not -name '*.gguf' -exec rm -rf {} +

        printf "    * Backup done\n\n"

    elif [ "$reinstall" -eq 1 ]; then
        printf "[+] Removing the existing $gaianet_base_dir directory ...\n\n"
        rm -rf $gaianet_base_dir
    fi
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

# Check if "$gaianet_base_dir/bin" directory exists
if [ ! -d "$gaianet_base_dir/bin" ]; then
    # If not, create it
    mkdir -p -m777 $gaianet_base_dir/bin
fi
bin_dir=$gaianet_base_dir/bin

# 1. Install `gaianet` CLI tool.
printf "[+] Installing gaianet CLI tool ...\n"
check_curl https://github.com/GaiaNet-AI/gaianet-node/releases/download/$version/gaianet $bin_dir/gaianet

if [ "$repo_branch" = "main" ]; then
    check_curl https://github.com/GaiaNet-AI/gaianet-node/releases/download/$version/gaianet $bin_dir/gaianet
else
    check_curl https://github.com/GaiaNet-AI/gaianet-node/raw/$repo_branch/gaianet $bin_dir/gaianet
fi

chmod u+x $bin_dir/gaianet
info "    * gaianet CLI tool is installed in $bin_dir"

# 2. Download default `config.json`
if [ "$upgrade" -eq 1 ]; then
    printf "[+] Recovering config.json ...\n"

    # recover config.json
    if [ -f "$gaianet_base_dir/backup/config.json" ]; then
        cp $gaianet_base_dir/backup/config.json $gaianet_base_dir/config.json

        if ! grep -q '"chat_batch_size":' $gaianet_base_dir/config.json; then
            # Prepend the field to the beginning of the JSON object
            sed_in_place '2i\
            "chat_batch_size": "16",
            ' "$gaianet_base_dir/config.json"
        fi

        if ! grep -q '"embedding_batch_size":' $gaianet_base_dir/config.json; then
            # Prepend the field to the beginning of the JSON object
            sed_in_place '2i\
            "embedding_batch_size": "512",
            ' "$gaianet_base_dir/config.json"
        fi

        info "    * The config.json is recovered in $gaianet_base_dir"
    else
        error "    * Failed to recover the config.json. Reason: the config.json does not exist in $gaianet_base_dir/backup/."
        exit 1
    fi
elif [ -f "$migrated_from_file" ] && tar -tf "$migrated_from_file" | grep -q "config.json"; then
    tar -xf "$migrated_from_file" -C $gaianet_base_dir config.json
else
    printf "[+] Downloading default config.json ...\n"

    if [ ! -f "$gaianet_base_dir/config.json" ]; then
        if [ "$repo_branch" = "main" ]; then
            check_curl https://github.com/GaiaNet-AI/gaianet-node/releases/download/$version/config.json $gaianet_base_dir/config.json
        else
            check_curl https://github.com/GaiaNet-AI/gaianet-node/raw/$repo_branch/config.json $gaianet_base_dir/config.json
        fi

        info "    * The default config file is downloaded in $gaianet_base_dir"
    else
        warning "    * Use the cached config file in $gaianet_base_dir"
    fi
fi

# 4. Install vector and download vector config file
if [ "$enable_vector" -eq 1 ]; then
    # Check if vector is installed
    if ! command -v vector &> /dev/null; then
        printf "[+] Installing vector ...\n"
        if curl --proto '=https' --tlsv1.2 -sSfL https://sh.vector.dev | VECTOR_VERSION=$vector_version bash -s -- -y; then
            info "    * The vector is installed."
        else
            error "    * Failed to install vector"
            exit 1
        fi
    fi
    # Check if vector.toml exists
    if [ ! -f "$gaianet_base_dir/vector.toml" ]; then
        printf "[+] Downloading vector config file ...\n"

        check_curl https://github.com/GaiaNet-AI/gaianet-node/releases/download/$version/vector.toml $gaianet_base_dir/vector.toml

        info "    * The vector.toml is downloaded in $gaianet_base_dir"
    fi
fi

# 5. Install WasmEdge and ggml plugin
printf "[+] Installing WasmEdge with wasi-nn_ggml plugin ...\n"
if [ -n "$ggmlcuda" ]; then
    if [ "$ggmlcuda" != "11" ] && [ "$ggmlcuda" != "12" ]; then
        error "Invalid argument to '--ggmlcuda' option. Possible values: 11, 12."
        exit 1
    fi

    if curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install_v2.sh | bash -s -- -v $wasmedge_version --tmpdir=$tmp_dir --ggmlcuda=$ggmlcuda; then
        source $HOME/.wasmedge/env
        wasmedge_path=$(which wasmedge)
        info "    * The $wasmedge_version is installed in $wasmedge_path."
    else
        error "    * Failed to install WasmEdge"
        exit 1
    fi
else
    if curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install_v2.sh | bash -s -- -v $wasmedge_version --tmpdir=$tmp_dir; then
        source $HOME/.wasmedge/env
        wasmedge_path=$(which wasmedge)
        info "    * The $wasmedge_version is installed in $wasmedge_path."
    else
        error "    * Failed to install WasmEdge"
        exit 1
    fi
fi

# 6. Install Qdrant binary and prepare directories

# 6.1 Inatall Qdrant binary
printf "[+] Installing Qdrant binary...\n"
if [ ! -f "$gaianet_base_dir/bin/qdrant" ] || [ "$reinstall" -eq 1 ]; then
    printf "    * Download Qdrant binary\n"
    if [ "$(uname)" == "Darwin" ]; then
        # download qdrant binary
        if [ "$target" = "x86_64" ]; then
            check_curl https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-apple-darwin.tar.gz $gaianet_base_dir/qdrant-x86_64-apple-darwin.tar.gz

            tar -xzf $gaianet_base_dir/qdrant-x86_64-apple-darwin.tar.gz -C $bin_dir
            rm $gaianet_base_dir/qdrant-x86_64-apple-darwin.tar.gz

            info "      The Qdrant binary is downloaded in $bin_dir"

        elif [ "$target" = "arm64" ]; then
            check_curl https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-apple-darwin.tar.gz $gaianet_base_dir/qdrant-aarch64-apple-darwin.tar.gz

            tar -xzf $gaianet_base_dir/qdrant-aarch64-apple-darwin.tar.gz -C $bin_dir
            rm $gaianet_base_dir/qdrant-aarch64-apple-darwin.tar.gz
            info "      The Qdrant binary is downloaded in $bin_dir"
        else
            error " * Unsupported architecture: $target, only support x86_64 and arm64 on MacOS"
            exit 1
        fi

    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # download qdrant statically linked binary
        if [ "$target" = "x86_64" ]; then
            check_curl https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-x86_64-unknown-linux-musl.tar.gz $gaianet_base_dir/qdrant-x86_64-unknown-linux-musl.tar.gz

            tar -xzf $gaianet_base_dir/qdrant-x86_64-unknown-linux-musl.tar.gz -C $bin_dir
            rm $gaianet_base_dir/qdrant-x86_64-unknown-linux-musl.tar.gz

            info "      The Qdrant binary is downloaded in $bin_dir"

        elif [ "$target" = "aarch64" ]; then
            check_curl https://github.com/qdrant/qdrant/releases/download/$qdrant_version/qdrant-aarch64-unknown-linux-musl.tar.gz $gaianet_base_dir/qdrant-aarch64-unknown-linux-musl.tar.gz

            tar -xzf $gaianet_base_dir/qdrant-aarch64-unknown-linux-musl.tar.gz -C $bin_dir
            rm $gaianet_base_dir/qdrant-aarch64-unknown-linux-musl.tar.gz
            info "      The Qdrant binary is downloaded in $bin_dir"
        else
            error " * Unsupported architecture: $target, only support x86_64 and aarch64 on Linux"
            exit 1
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

# 6.2 Init qdrant directory
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
        sed_in_place 's/telemetry_disabled: false/telemetry_disabled: true/' "$config_file"
    fi

    printf "\n"
fi

# 7. Download LlamaEdge API server
printf "[+] Downloading LlamaEdge API server ...\n"
# download rag-api-server.wasm
check_curl https://github.com/LlamaEdge/rag-api-server/releases/download/$rag_api_server_version/rag-api-server.wasm $gaianet_base_dir/rag-api-server.wasm
# download llama-api-server.wasm
check_curl https://github.com/LlamaEdge/LlamaEdge/releases/download/$llama_api_server_version/llama-api-server.wasm $gaianet_base_dir/llama-api-server.wasm

info "    * The rag-api-server.wasm and llama-api-server.wasm are downloaded in $gaianet_base_dir"

# 8. Download dashboard to $gaianet_base_dir
if ! command -v tar &> /dev/null; then
    echo "tar could not be found, please install it."
    exit 1
fi
printf "[+] Downloading dashboard ...\n"
if [ ! -d "$gaianet_base_dir/dashboard" ] || [ "$reinstall" -eq 1 ]; then
    if [ -d "$gaianet_base_dir/gaianet-node" ]; then
        rm -rf $gaianet_base_dir/gaianet-node
    fi

    check_curl https://github.com/GaiaNet-AI/chatbot-ui/releases/download/$dashboard_version/dashboard.tar.gz $gaianet_base_dir/dashboard.tar.gz
    tar xzf $gaianet_base_dir/dashboard.tar.gz -C $gaianet_base_dir
    rm -rf $gaianet_base_dir/dashboard.tar.gz

    info "    * The dashboard is downloaded in $gaianet_base_dir"
else
    warning "    * Use the cached dashboard in $gaianet_base_dir"
fi

# 9. Download registry.wasm
if [ ! -f "$gaianet_base_dir/registry.wasm" ] || [ "$reinstall" -eq 1 ]; then
    printf "[+] Downloading registry.wasm ...\n"
    check_curl https://github.com/GaiaNet-AI/gaianet-node/raw/main/utils/registry/registry.wasm $gaianet_base_dir/registry.wasm
    info "    * The registry.wasm is downloaded in $gaianet_base_dir"
else
    warning "    * Use the cached registry.wasm in $gaianet_base_dir"
fi

# 10. Generate node ID
if [ "$upgrade" -eq 1 ]; then
    printf "[+] Recovering node ID ...\n"

    # recover the keystore file
    if [ -f "$gaianet_base_dir/backup/$keystore_filename" ]; then
        cp $gaianet_base_dir/backup/$keystore_filename $gaianet_base_dir/
        info "    * The keystore file is recovered in $gaianet_base_dir"
    else
        error "Failed to recover the keystore file. Reason: the keystore file does not exist in $gaianet_base_dir/backup/."
        exit 1
    fi

    # recover the nodeid.json
    if [ -f "$gaianet_base_dir/backup/nodeid.json" ]; then
        cp $gaianet_base_dir/backup/nodeid.json $gaianet_base_dir/nodeid.json
        info "    * The node ID is recovered in $gaianet_base_dir"
    else
        error "Failed to recover the node ID. Reason: the nodeid.json does not exist in $gaianet_base_dir/backup/."
        exit 1
    fi
elif [ -f "$migrated_from_file" ] && tar -tf "$migrated_from_file" | grep -q "nodeid.json"; then
    tar -xf "$migrated_from_file" -C $gaianet_base_dir nodeid.json
    migrate_keystore_filename=$(grep '"keystore":' $gaianet_base_dir/nodeid.json | awk -F'"' '{print $4}')
    if [ -z "$migrate_keystore_filename" ]; then
        error "Failed to read the 'keystore' field from backup nodeid.json."
        exit 1
    else
        if tar -tf "$migrated_from_file" | grep -q "$migrate_keystore_filename"; then
            tar -xf "$migrated_from_file" -C $gaianet_base_dir $migrate_keystore_filename
        else
            error "Failed to copy the keystore file. Reason: the keystore file does not exist in backup file."
            exit 1
        fi
    fi
else
    # download the default nodeid.json
    if [ ! -f "$gaianet_base_dir/nodeid.json" ]; then
        check_curl https://github.com/GaiaNet-AI/gaianet-node/releases/download/$version/nodeid.json $gaianet_base_dir/nodeid.json
    fi

    printf "[+] Generating node ID ...\n"
    cd $gaianet_base_dir
    wasmedge --dir .:. registry.wasm
    printf "\n"
fi

# 11. Install gaia-frp
printf "[+] Installing gaia-frp...\n"
# Check if the directory exists, if not, create it
if [ ! -d "$gaianet_base_dir/gaia-frp" ]; then
    mkdir -p -m777 $gaianet_base_dir/gaia-frp
fi
cd $gaianet_base_dir
gaia_frp_version="v0.1.2"
printf "    * Download gaia-frp binary\n"
if [ "$(uname)" == "Darwin" ]; then
    if [ "$target" = "x86_64" ]; then
        check_curl https://github.com/GaiaNet-AI/gaia-frp/releases/download/$gaia_frp_version/gaia_frp_${gaia_frp_version}_darwin_amd64.tar.gz $gaianet_base_dir/gaia_frp_${gaia_frp_version}_darwin_amd64.tar.gz

        tar -xzf $gaianet_base_dir/gaia_frp_${gaia_frp_version}_darwin_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaia-frp
        rm $gaianet_base_dir/gaia_frp_${gaia_frp_version}_darwin_amd64.tar.gz

        info "      gaia-frp is downloaded in $gaianet_base_dir"
    elif [ "$target" = "arm64" ] || [ "$target" = "aarch64" ]; then
        check_curl https://github.com/GaiaNet-AI/gaia-frp/releases/download/$gaia_frp_version/gaia_frp_${gaia_frp_version}_darwin_arm64.tar.gz $gaianet_base_dir/gaia_frp_${gaia_frp_version}_darwin_arm64.tar.gz

        tar -xzf $gaianet_base_dir/gaia_frp_${gaia_frp_version}_darwin_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaia-frp
        rm $gaianet_base_dir/gaia_frp_${gaia_frp_version}_darwin_arm64.tar.gz

        info "      gaia-frp is downloaded in $gaianet_base_dir"
    else
        error " * Unsupported architecture: $target, only support x86_64 and arm64 on MacOS"
        exit 1
    fi

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # download gaia-frp statically linked binary
    if [ "$target" = "x86_64" ]; then
        check_curl https://github.com/GaiaNet-AI/gaia-frp/releases/download/$gaia_frp_version/gaia_frp_${gaia_frp_version}_linux_amd64.tar.gz $gaianet_base_dir/gaia_frp_${gaia_frp_version}_linux_amd64.tar.gz

        tar --warning=no-unknown-keyword -xzf $gaianet_base_dir/gaia_frp_${gaia_frp_version}_linux_amd64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaia-frp
        rm $gaianet_base_dir/gaia_frp_${gaia_frp_version}_linux_amd64.tar.gz

        info "      gaia-frp is downloaded in $gaianet_base_dir"
    elif [ "$target" = "arm64" ] || [ "$target" = "aarch64" ]; then
        check_curl https://github.com/GaiaNet-AI/gaia-frp/releases/download/$gaia_frp_version/gaia_frp_${gaia_frp_version}_linux_arm64.tar.gz $gaianet_base_dir/gaia_frp_${gaia_frp_version}_linux_arm64.tar.gz

        tar --warning=no-unknown-keyword -xzf $gaianet_base_dir/gaia_frp_${gaia_frp_version}_linux_arm64.tar.gz --strip-components=1 -C $gaianet_base_dir/gaia-frp
        rm $gaianet_base_dir/gaia_frp_${gaia_frp_version}_linux_arm64.tar.gz

        info "      gaia-frp is downloaded in $gaianet_base_dir"
    else
        error " * Unsupported architecture: $target, only support x86_64 and arm64 on Linux"
        exit 1
    fi

elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    error "For Windows users, please run this script in WSL."
    exit 1
else
    error "Only support Linux, MacOS and Windows."
    exit 1
fi

# Copy frpc binary from $gaianet_base_dir/gaia-frp to $gaianet_base_dir/bin
printf "    * Install frpc binary\n"
cp $gaianet_base_dir/gaia-frp/frpc $gaianet_base_dir/bin/
info "      frpc binary is installed in $gaianet_base_dir/bin"

# 12. Download frpc.toml, generate a subdomain and print it
if [ "$upgrade" -eq 1 ]; then
    # recover the frpc.toml
    if [ -f "$gaianet_base_dir/backup/frpc.toml" ]; then
        printf "    * Recover frpc.toml\n"
        cp $gaianet_base_dir/backup/frpc.toml $gaianet_base_dir/gaia-frp/frpc.toml
        info "      frpc.toml is recovered in $gaianet_base_dir/gaia-frp"
    else
        error "Failed to recover the frpc.toml. Reason: the frpc.toml does not exist in $gaianet_base_dir/backup/."
        exit 1
    fi
elif [ -f "$migrated_from_file" ] && ( tar -tf "$migrated_from_file" | grep -q "gaianet-domain/frpc.toml" || tar -tf "$migrated_from_file" | grep -q "gaia-frp/frpc.toml" ); then
    if tar -tf "$migrated_from_file" | grep -q "gaianet-domain/frpc.toml"; then
        tar -xf "$migrated_from_file" --strip-components=1 -C $gaianet_base_dir/gaia-frp gaianet-domain/frpc.toml
    else
        tar -xf "$migrated_from_file" --strip-components=1 -C $gaianet_base_dir/gaia-frp gaia-frp/frpc.toml
    fi
else
    printf "    * Download frpc.toml\n"
    check_curl_silent https://github.com/GaiaNet-AI/gaianet-node/releases/download/$version/frpc.toml $gaianet_base_dir/gaia-frp/frpc.toml
    info "      frpc.toml is downloaded in $gaianet_base_dir/gaia-frp"
fi

# Read address from config.json as node subdomain
subdomain=$(awk -F'"' '/"address":/ {print $4}' $gaianet_base_dir/config.json)

# Check if the subdomain was read correctly
if [ -z "$subdomain" ]; then
    error "Failed to read the address from config.json."
    exit 1
fi

# Read domain from config.json
gaia_frp=$(awk -F'"' '/"domain":/ {print $4}' $gaianet_base_dir/config.json)


if [ "$upgrade" -eq 1 ]; then
    # recover deviceid.txt
    if [ -f "$gaianet_base_dir/backup/deviceid.txt" ]; then
        cp $gaianet_base_dir/backup/deviceid.txt $gaianet_base_dir/deviceid.txt

        info "    * The deviceid.txt is recovered in $gaianet_base_dir"
    else
        warning "    * The deviceid.txt does not exist in $gaianet_base_dir/backup/. Will generate a new one."
    fi
fi

device_id_file="$gaianet_base_dir/deviceid.txt"

# Check if the device_id file exists
if [ -f "$device_id_file" ]; then
    # The file exists, read device_id from the file
    device_id=$(cat "$device_id_file")
    # Check if the device_id is empty
    if [ -z "$device_id" ]; then
        # device_id is empty, generate a new one
        device_id="device-$(openssl rand -hex 12)"
        echo "$device_id" > "$device_id_file"
    fi
else
    # The file does not exist, generate a new device_id and save it to the file
    device_id="device-$(openssl rand -hex 12)"
    echo "$device_id" > "$device_id_file"
fi

sed_in_place "/^[[:space:]]*\"server_health_url\"/ s|\(.*\/\)[^/]*\(\"[,]*\)|\1$subdomain\2|" $gaianet_base_dir/config.json
sed_in_place "/^[[:space:]]*\"server_info_url\"/ s|\(.*\/\)[^/]*\(\"[,]*\)|\1$subdomain\2|" $gaianet_base_dir/config.json
sed_in_place "s/subdomain = \".*\"/subdomain = \"$subdomain\"/g" $gaianet_base_dir/gaia-frp/frpc.toml
sed_in_place "s/serverAddr = \".*\"/serverAddr = \"$gaia_frp\"/g" $gaianet_base_dir/gaia-frp/frpc.toml
sed_in_place "s/name = \".*\"/name = \"$subdomain.$gaia_frp\"/g" $gaianet_base_dir/gaia-frp/frpc.toml
sed_in_place "s/metadatas.deviceId = \".*\"/metadatas.deviceId = \"$device_id\"/g" $gaianet_base_dir/gaia-frp/frpc.toml

# Remove all files in the directory except for frpc and frpc.toml
find $gaianet_base_dir/gaia-frp -type f -not -name 'frpc.toml' -exec rm -f {} \;

# 13. Install server assistant
printf "[+] Installing server assistant...\n"
if [ "$(uname)" == "Darwin" ]; then

    if [ "$target" = "x86_64" ]; then
        check_curl https://github.com/GaiaNet-AI/server-assistant/releases/download/$assistant_version/server-assistant-x86_64-apple-darwin.tar.gz $bin_dir/server-assistant.tar.gz

    elif [ "$target" = "arm64" ]; then
        check_curl https://github.com/GaiaNet-AI/server-assistant/releases/download/$assistant_version/server-assistant-aarch64-apple-darwin.tar.gz $bin_dir/server-assistant.tar.gz

    else
        error " * Unsupported architecture: $target, only support x86_64 and arm64 on MacOS"
        exit 1
    fi

elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then

    if [ "$target" = "x86_64" ]; then
        check_curl https://github.com/GaiaNet-AI/server-assistant/releases/download/$assistant_version/server-assistant-x86_64-unknown-linux-gnu.tar.gz $bin_dir/server-assistant.tar.gz
    else
        error " * Unsupported architecture: $target, only support x86_64 on Linux"
        exit 1
    fi

else
    error "Only support Linux, MacOS and Windows(WSL)."
    exit 1
fi

tar -xzf $bin_dir/server-assistant.tar.gz -C $bin_dir
rm $bin_dir/server-assistant.tar.gz
if [ -f $bin_dir/SHA256SUM ]; then
    rm $bin_dir/SHA256SUM
fi

info "    * server assistant is installed in $bin_dir"


if [ "$upgrade" -eq 1 ]; then

    printf "[+] COMPLETED! The gaianet node has been upgraded to v$version.\n\n"

    info ">>> Next, you should run the command 'gaianet init' to initialize the GaiaNet node."

else
    printf "[+] COMPLETED! The gaianet node has been installed successfully.\n\n"

    info "Your node ID is $subdomain. Please register it in your portal account to receive awards!"

    # Command to append
    cmd="export PATH=\"$bin_dir:\$PATH\""

    shell="${SHELL#${SHELL%/*}/}"
    shell_rc=".""$shell""rc"

    # Check if the shell is zsh or bash
    if [[ $shell == *'zsh'* ]]; then
        # If zsh, append to .zprofile
        if ! grep -Fxq "$cmd" $HOME/.zprofile
        then
            echo "$cmd" >> $HOME/.zprofile
        fi

        # If zsh, append to .zshrc
        if ! grep -Fxq "$cmd" $HOME/.zshrc
        then
            echo "$cmd" >> $HOME/.zshrc
        fi

    elif [[ $shell == *'bash'* ]]; then

        # If bash, append to .bash_profile
        if ! grep -Fxq "$cmd" $HOME/.bash_profile
        then
            echo "$cmd" >> $HOME/.bash_profile
        fi

        # If bash, append to .bashrc
        if ! grep -Fxq "$cmd" $HOME/.bashrc
        then
            echo "$cmd" >> $HOME/.bashrc
        fi
    fi

    info ">>> Next, you should initialize the GaiaNet node with the LLM and knowledge base. To initialize the GaiaNet node, you need to\n>>> * Run the command 'source $HOME/$shell_rc' to make the gaianet CLI tool available in the current shell;\n>>> * Run the command 'gaianet init' to initialize the GaiaNet node."

fi

exit 0
