# GaiaNet Installer v2

> [!NOTE]
> GaiaNet Installer v2 is still in active development. Please report any issues you encounter.

Todo list:

- [x] install_v2.sh
  - [x] Download default config file
  - [x] Download nodeid.json
  - [x] Install WasmEdge with wasi-nn_ggml plugin
  - [x] Install Qdrant binary and initialize Qdrant directory
  - [x] Download rag-api-server.wasm
  - [x] Download dashboard
  - [x] Install gaianet-domain (frpc binary + frpc.toml)
  - [x] Generates keys

- [ ] gaianet.sh
  - [x] `gaianet init`
    - [x] `gaianet init <url-to-config.json>`
    - [ ] `gaianet init paris_guide`
    - [ ] `gaianet init berkeley_cs_101_ta`
    - [ ] `gaianet init vitalik_buterin`
  - [x] `gaianet run`
    - [x] `gaianet run --local`
  - [x] `gaianet stop`
    - [x] `gaianet stop --force`
  - [ ] `gaianet config`
    - [x] `gaianet config chat <url>`
    - [x] `gaianet config chat_ctx_size <size>`
    - [x] `gaianet config embedding <url>`
    - [x] `gaianet config embedding_ctx_size <size>`
    - [ ] `gaianet config system_prompt <prompt>`

## install_v2.sh

```bash
gaianet-node/v2$ bash install_v2.sh
```

<details><summary> The output should look like below: </summary>

```console
[+] Downloading default config file ...

[+] Downloading nodeid.json ...

[+] Installing WasmEdge with wasi-nn_ggml plugin ...

Info: Detected Linux-x86_64

Info: WasmEdge Installation at /home/azureuser/.wasmedge

Info: Fetching WasmEdge-0.13.5

/tmp/wasmedge.2884467 ~/gaianet
######################################################################## 100.0%
~/gaianet
Info: Fetching WasmEdge-GGML-Plugin

Info: Detected CUDA version:

/tmp/wasmedge.2884467 ~/gaianet
######################################################################## 100.0%
~/gaianet
Installation of wasmedge-0.13.5 successful
WasmEdge binaries accessible

    The WasmEdge Runtime wasmedge version 0.13.5 is installed in /home/azureuser/.wasmedge/bin/wasmedge.


[+] Installing Qdrant binary...
    * Download Qdrant binary
################################################################################################## 100.0%

    * Initialize Qdrant directory

[+] Downloading the rag-api-server.wasm ...
################################################################################################## 100.0%

[+] Downloading dashboard ...
################################################################################################## 100.0%
```

</details>

## gaianet.sh

```bash
gaianet-node/v2$ bash gaianet.sh --help
Usage: gaianet.sh {config|init|run|stop} [arg]

Subcommands:
  config <arg>  Update the configuration.
                Available args: chat_url, chat_ctx_size, embedding_url, embedding_ctx_size, system_prompt
  init [arg]    Initialize with optional argument.
                Available args: paris_guide, berkeley_cs_101_ta, vitalik_buterin, <url-to-config.json>
  run           Run the program
  stop [arg]    Stop the program.
                Available args: --force

Options:
  --help        Show this help message
```

### Update configuration

Using `bash gaianet.sh config` subcommand can update the following fields defined in the `config.json` file:

- `chat`: Url of the chat model
- `chat_ctx_size`: Context size of the chat model
- `embedding`: Url of the embedding model
- `embedding_ctx_size`: Context size of the embedding model
- `system_prompt`: System prompt

To update the `chat` field, for example, use the following command:

```bash
bash gaianet.sh config chat https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf
```

To update the `chat_ctx_size` field, for example, use the following command:

```bash
bash gaianet.sh config chat_ctx_size 5120
```

### Initialize GaiaNet-node

```bash
gaianet-node/v2$ bash gaianet.sh init
```

<details><summary> The output should look like below: </summary>

```bash
[+] Downloading Llama-2-7b-chat-hf-Q5_K_M.gguf ...
############################################################################################################################## 100.0%############################################################################################################################## 100.0%

[+] Downloading all-MiniLM-L6-v2-ggml-model-f16.gguf ...

############################################################################################################################## 100.0%############################################################################################################################## 100.0%

[+] Creating 'default' collection in the Qdrant instance ...

    * Start a Qdrant instance ...

    * Remove the existed 'default' Qdrant collection ...

    * Download Qdrant collection snapshot ...
############################################################################################################################## 100.0%############################################################################################################################## 100.0%

    * Import the Qdrant collection snapshot ...

    * Recovery is done successfully
```

</details>

### Start GaiaNet-node

```bash
gaianet-node/v2$ bash gaianet.sh run
```

<details><summary> The output should look like below: </summary>

```bash
[+] Starting Qdrant instance ...

    Qdrant instance started with pid: 39762

[+] Starting LlamaEdge API Server ...

    Run the following command to start the LlamaEdge API Server:

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"


    LlamaEdge API Server started with pid: 39796
```

</details>

### Stop GaiaNet-node

```bash
gaianet-node/v2$ bash gaianet.sh stop
```

<details><summary> The output should look like below: </summary>

```bash
[+] Stopping Qdrant instance ...
[+] Stopping API server ...
```

To force stop the GaiaNet-node, use the following command:

```bash
gaianet-node/v2$ bash gaianet.sh stop --force
```

</details>
