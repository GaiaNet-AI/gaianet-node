# 運行您自己的 GaiaNet 節點

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

[日文(日本語)](README-ja.md) | [簡體中文](README-cn.md) | [土耳其文 (Türkçe)](README-tr.md) | [波斯文(فارسی)](README-fa.md) | [阿拉伯文 (العربية)](README-ar.md) | [印尼文](README-id.md) | [俄文 (русскийة)](README-ru.md) | [葡萄牙文 (português)](README-pt.md) | 我們需要您的幫助將此 README 翻譯成您的母語。

喜歡我們的工作嗎？⭐ 給我們顆星星！

查看我們的[官方文檔](https://docs.gaianet.ai/)和一本關於如何自定義開源模型的 [Manning 電子書](https://www.manning.com/liveprojectseries/open-source-llms-on-your-own-computer)。

---

## 快速開始

在 Mac、Linux 或 Windows WSL 上使用單行命令安裝默認節點。

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

然後，按照提示設置環境路徑。命令行將以 `source` 開頭。

初始化節點。它將下載 `$HOME/gaianet/config.json` 文件中指定的模型文件和向量數據庫文件，由於文件較大，可能需要幾分鐘時間。

```bash
gaianet init
```

啟動節點。

```bash
gaianet start
```

腳本會在控制台上打印官方節點地址，如下所示。
您可以在瀏覽器中打開該 URL 以查看節點資訊，然後與節點上的 AI 代理聊天。

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

要停止節點，您可以運行以下腳本。

```bash
gaianet stop
```

## 安裝指南

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary> 輸出應該如下所示： </summary>

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

默認情況下，它安裝在 `$HOME/gaianet` 目錄中。您也可以選擇安裝到其他目錄。

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## 初始化節點

```
gaianet init
```

<details><summary> 輸出應該如下所示： </summary>

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

`init` 命令根據 `$HOME/gaianet/config.json` 文件初始化節點。您可以使用我們預設的一些配置。例如，下面的命令使用 llama-3 8B 模型和倫敦旅遊指南作為知識庫初始化節點。

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json
```

要查看預設配置列表，您可以執行 `gaianet init --help`。
除了像 `gaianet_docs` 這樣的預設配置外，您還可以傳遞一個 URL 指向您自己的 `config.json`，以使節點初始化為您想要的狀態。

如果您需要在另一個目錄中 `init` 一個已安裝的節點，請執行以下操作。

```bash
gaianet init --base $HOME/gaianet.alt
```

## 啟動節點

```
gaianet start
```

<details><summary> 輸出應該如下所示： </summary>

```bash
[+] Starting Qdrant instance ...

    Qdrant instance started with pid: 39762

[+] Starting LlamaEdge API Server ...

    Run the following command to start the LlamaEdge API Server:

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"


    LlamaEdge API Server started with pid: 39796
```

</details>

您可以啟動節點以供本地使用。它將僅通過 `localhost` 訪問，不會在任何 GaiaNet 域的公共 URL 上可用。

```bash
gaianet start --local-only
```

您也可以啟動安裝在另一個基本目錄中的節點。

```bash
gaianet start --base $HOME/gaianet.alt
```

### 停止節點

```bash
gaianet stop
```

<details><summary> 輸出應該如下所示： </summary>

```bash
[+] Stopping WasmEdge, Qdrant and frpc ...
```

</details>

停止安裝在另一個基本目錄中的節點。

```bash
gaianet stop --base $HOME/gaianet.alt
```

### 更新配置

使用 `gaianet config` 子命令可以更新 `config.json` 文件中定義的關鍵字段。更新配置後，您必須再次運行 `gaianet init`。

例如，要更新 `chat` 字段，請使用以下命令：

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```

例如，要更新 `chat_ctx_size` 字段，請使用以下命令：

```bash
gaianet config --chat-ctx-size 5120
```

以下是 `config` 子命令的所有選項：

```console
$ gaianet config --help

用法：gaianet config [選項]

選項：
  --chat-url <url>               更新聊天模型的 URL。
  --chat-ctx-size <val>          更新聊天模型的上下文大小。
  --embedding-url <url>          更新嵌入模型的 URL。
  --embedding-ctx-size <val>     更新嵌入模型的上下文大小。
  --prompt-template <val>        更新聊天模型的提示模板。
  --port <val>                   更新 LlamaEdge API 服務器的端口。
  --system-prompt <val>          更新系統提示。
  --rag-prompt <val>             更新 rag 提示。
  --rag-policy <val>             更新 rag 策略 [可能的值：system-message, last-user-message]。
  --reverse-prompt <val>         更新反向提示。
  --domain <val>                 更新 GaiaNet 節點的域名。
  --snapshot <url>               更新 Qdrant 快照。
  --qdrant-limit <val>           更新要返回的最大結果數。
  --qdrant-score-threshold <val> 更新結果的最小分數閾值。
  --base <path>                  GaiaNet 節點的基本目錄。
  --help                         顯示此幫助資訊
```

玩得開心！