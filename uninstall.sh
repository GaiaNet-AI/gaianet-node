#!/bin/bash

set -e

# path to the default gaianet base directory. It could be changed by the --base option
gaianet_base_dir="$HOME/gaianet"

version="v0.2.1"

# print in red color
RED=$'\e[0;31m'
# print in green color
GREEN=$'\e[0;32m'
# print in yellow color
YELLOW=$'\e[0;33m'
# No Color
NC=$'\e[0m'

info() {
    printf "${GREEN}$1${NC}\n\n"
}

error() {
    printf "${RED}$1${NC}\n\n"
}

warning() {
    printf "${YELLOW}$1${NC}\n\n"
}

function print_usage {
    printf "Usage:\n"
    printf "  ./uninstall.sh [Options]\n\n"
    printf "Options:\n"
    printf "  --base <Path>     Specify a path to the gaianet base directory\n"
    printf "  --version         Print version\n"
    printf "  --help            Print usage\n"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --base)
            gaianet_base_dir="$2"
            shift
            shift
            ;;
        --version)
            echo "Gaianet-node Uninstaller $version"
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


# 1. Stop WasmEdge, Qdrant and frpc
if command -v gaianet > /dev/null 2>&1; then
    gaianet stop
    printf "\n"
fi


# 2. Remove the gaianet base directory
if [ -d "$gaianet_base_dir" ]; then
    printf "[+] Removing the gaianet base directory ...\n"
    rm -rf $gaianet_base_dir
    printf "\n"
fi

if [ -f "/usr/local/bin/gaianet" ]; then
    printf "[+] Removing gaianet binary from /usr/local/bin ...\n"
    sudo rm "/usr/local/bin/gaianet"
    printf "\n"
fi


# 3. Remove WasmEdge
if command -v wasmedge > /dev/null 2>&1; then
    printf "[+] Uninstall WasmEdge ...\n"
    bash <(curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/uninstall.sh) -q
    printf "\n"
fi


# 4. Clean up the environment variables
printf "[+] Remove the path from the shell rc file ...\n"

shell="${SHELL#${SHELL%/*}/}"
shell_rc=".""$shell""rc"

info "shell: $shell"
info "shell_rc: $HOME/$shell_rc"

if [[ -f "${HOME}/${shell_rc}" ]]; then
    line_num=$(grep -n "export PATH=\"$gaianet_base_dir/bin:\$PATH\"" "$HOME/${shell_rc}" | cut -d : -f 1)

    [ "$line_num" != "" ] && sed -i.gaianet_backup -e "${line_num}"'d' "${HOME}/${shell_rc}"
fi

if [[ -f "${HOME}/.zprofile" ]]; then
    line_num="$(grep -n "export PATH=\"$gaianet_base_dir/bin:\$PATH\"" "${HOME}/.zprofile" | cut -d : -f 1)"

    [ "$line_num" != "" ] && sed -i.gaianet_backup -e "${line_num}"'d' "${HOME}/.zprofile"
fi

if [[ -f "${HOME}/.bash_profile" ]]; then
    line_num="$(grep -n "export PATH=\"$gaianet_base_dir/bin:\$PATH\"" "${HOME}/.bash_profile" | cut -d : -f 1)"

    [ "$line_num" != "" ] && sed -i.gaianet_backup -e "${line_num}"'d' "${HOME}/.bash_profile"
fi


info ">>> Next, run the command 'source $HOME/$shell_rc' to make the uninstallation effective in the current shell."


