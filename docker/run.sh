#!/bin/bash

gaianet_base_dir="/root/gaianet/"

using_node_id=$(awk -F'"' '/"address":/ {print $4}' $gaianet_base_dir/config.json)
initial_node_id="0x78059e5b7f88aba831f7f7254c6d343072df4dc4"

if [[ "${using_node_id,,}" == "${initial_node_id,,}" ]]; then

        echo -e "\033[0;32m\nFound initial nodeId. Refreshing...\033[0"

        # Replace the serverAddr & subdomain in frpc.toml
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sed_i_cmd="sed -i"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            sed_i_cmd="sed -i ''"
        else
            echo "Unsupported OS"
            exit 1
        fi
        
        
        # regenerate nodeId
        echo "{}" > ${gaianet_base_dir}nodeid.json
        sed_i_cmd 's/[[:space:]]*"address": ".*/"address": "",/' ${gaianet_base_dir}config.json
        echo -e "\033[0;32m\nOriginal configuration cleared.\nGenerating new nodeId now...\033[0"
        cd ${gaianet_base_dir}
        wasmedge --dir .:. registry.wasm
        echo -e "\033[0;32m\nYour new NodeId has been Generated:\033[0"
        
        # generate device id
        echo -e "\033[0;32m\nGenerating new deviceId...\033[0"
        device_id_file="$gaianet_base_dir/deviceid.txt"
        device_id="device-$(openssl rand -hex 12)"
        echo "$device_id" > "$device_id_file"
        echo -e "\033[0;32m\nYour new deviceId has been Generated:\033[0"
        
        # update subdomain link
        echo -e "\033[0;32mUpdating subdomain link...\033[0"
        subdomain=$(awk -F'"' '/"address":/ {print $4}' $gaianet_base_dir/config.json)
        gaianet_domain=$(awk -F'"' '/"domain":/ {print $4}' $gaianet_base_dir/config.json)
        $sed_i_cmd "s/subdomain = \".*\"/subdomain = \"$subdomain\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
        $sed_i_cmd "s/name = \".*\"/name = \"$subdomain.$gaianet_domain\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml
        $sed_i_cmd "s/metadatas.deviceId = \".*\"/metadatas.deviceId = \"$device_id\"/g" $gaianet_base_dir/gaianet-domain/frpc.toml

else

        echo -e "\033[0;32m\nUsing nodeId of your own. Skip refreshing nodeId.\033[0"
fi

# pring using info
echo -e "\033[0;32m\nUse node info:\033[0"
node_info=$(gaianet info)
echo -e $node_info

# start node
echo -e "\033[0;32m\nStarting node...\033[0"
${gaianet_base_dir}bin/gaianet init
${gaianet_base_dir}bin/gaianet start

# print info and log
# ${gaianet_base_dir}bin/gaianet info
tail -f ${gaianet_base_dir}log/start-llamaedge.log
