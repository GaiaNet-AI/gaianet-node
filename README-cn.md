# 运行自己的 GaiaNet 节点

<p align="center">
  <a href="https://discord.gg/gaianet-ai">
    <img src="https://img.shields.io/badge/chat-Discord-7289DA?logo=discord" alt="GaiaNet Discord">
  </a>
  <a href="https://twitter.com/Gaianet_AI">
    <img src="https://img.shields.io/badge/Twitter-1DA1F2?logo=twitter&amp;logoColor=white" alt="GaiaNet Twitter">
  </a>
   <a href="https://www.gaianet.ai/">
    <img src="https://img.shields.io/website?up_message=Website&url=https://www.gaianet.ai/" alt="Gaianet website">
  </a>
</p>

> 如果您在中国大陆，需要翻墙。而且不只是要浏览器翻墙，命令行也要使用代理翻墙。同时，localhost 不应该有代理：在终端命令行输入 `export no_proxy=localhost,127.0.0.0/8`.

## 快速入门

在 Mac、Linux 或 Windows WSL 上只需一行命令即可安装默认节点软件栈。

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

初始化节点。这将下载 `$HOME/gaianet/config.json` 文件中指定的模型文件和矢量数据库文件，由于文件较大，可能需要几分钟时间。

```bash
gaianet init
```

启动节点。

```bash
gaianet start
```

脚本会在控制台上显示官方节点地址，如下所示。

您可以打开浏览器访问该 URL，查看节点信息并与节点上的人工智能代理聊天。

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.gaianet.xyz
```

要停止节点，可以运行以下脚本。

```bash
gaianet stop
```

## 安装指南

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary> 输出结果应如下所示： </summary>

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

默认情况下，它会安装到 `$HOME/gaianet` 目录中。您也可以选择安装在其他目录下。

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## 初始化节点

```
gaianet init
```

<details><summary> 输出结果应如下所示： </summary>

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

`init` 命令根据 `$HOME/gaianet/config.json` 文件初始化节点。您可以使用我们的一些预设配置。例如，下面的命令初始化了一个用 llama-3 8B 模型加上伦敦旅游指南作为知识库的节点。

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json
```

要查看预设配置列表，可以执行 `gaianet init --help` 命令。

除了像 `gaianet_docs` 这样的预设配置外，您还可以向 `config.json` 传递一个 URL，以便将节点初始化为你想要的状态。

如果需要 `init` 安装在其他目录下的节点，可以这样做：

```bash
gaianet init --base $HOME/gaianet.alt
```

## 启动节点

```
gaianet start
```

<details><summary> 输出结果应如下所示： </summary>

```bash
[+] Starting Qdrant instance ...

    Qdrant instance started with pid: 39762

[+] Starting LlamaEdge API Server ...

    Run the following command to start the LlamaEdge API Server:

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"


    LlamaEdge API Server started with pid: 39796
```

</details>

您可以在本地启动节点。它只能通过 `localhost` 访问，而不能通过 GaiaNet 域的公共 URL 访问。

```bash
gaianet start --local-only
```

您也可以启动安装在其他目录下的节点。

```bash
gaianet start --base $HOME/gaianet.alt
```

### 停止节点

```bash
gaianet stop
```

<details><summary> 输出结果应如下所示： </summary>

```bash
[+] Stopping WasmEdge, Qdrant and frpc ...
```

</details>

停止安装在其他目录下的节点。

```bash
gaianet stop --base $HOME/gaianet.alt
```

### 更新配置

使用 `gaianet config` 子命令可以更新 `config.json` 文件中定义的字段。更新配置后，必须再次运行 `gaianet init` 。

例如，要更新 `chat` 字段，请使用以下命令：

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```

例如，要更新 `chat_ctx_size` 字段，请使用以下命令：

```bash
gaianet config --chat-ctx-size 5120
```

以下是 `config` 子命令的所有选项。

```console
$ gaianet config --help

Usage: gaianet config [OPTIONS]

Options:
  --chat-url <url>               Update the url of chat model.
  --chat-ctx-size <val>          Update the context size of chat model.
  --embedding-url <url>          Update the url of embedding model.
  --embedding-ctx-size <val>     Update the context size of embedding model.
  --prompt-template <val>        Update the prompt template of chat model.
  --port <val>                   Update the port of LlamaEdge API Server.
  --system-prompt <val>          Update the system prompt.
  --rag-prompt <val>             Update the rag prompt.
  --rag-policy <val>             Update the rag policy [Possible values: system-message, last-user-message].
  --reverse-prompt <val>         Update the reverse prompt.
  --domain <val>                 Update the domain of GaiaNet node.
  --snapshot <url>               Update the Qdrant snapshot.
  --qdrant-limit <val>           Update the max number of result to return.
  --qdrant-score-threshold <val> Update the minimal score threshold for the result.
  --base <path>                  The base directory of GaiaNet node.
  --help                         Show this help message
```

玩得开心！
