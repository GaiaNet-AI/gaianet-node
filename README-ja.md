# 自分のGaiaNetノードを実行する

## クイックスタート

Mac、Linux、またはWindows WSLで、一行のコマンドでデフォルトのノードソフトウェアスタックをインストールします。


```
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```


ノードを初期化します。`$HOME/gaianet/config.json`ファイルに指定されたモデルファイルとベクターデータベースファイルをダウンロードしますが、ファイルが大きいため数分かかる場合があります。


```
gaianet init
```


ノードを開始します。


```
gaianet start
```


スクリプトは、以下のように公式のノードアドレスをコンソールに表示します。
そのURLをブラウザで開いて、ノードの情報を確認し、ノード上のAIエージェントとチャットできます。


```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.gaianet.xyz
```


ノードを停止するには、次のスクリプトを実行します。


```
gaianet stop
```



## インストールガイド

```
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```


<details><summary> 出力は以下のようになります: </summary>


```
Password:

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

デフォルトのインストールスクリプトは `sudo` 権限が必要です。`sudo` の権限があり、パスワードを求められます。
`sudo` 権限なしでインストールする場合は、以下のコマンドを使用できます。ただし、`sudo` なしでインストールする場合は、後続のステップでCLIコマンドを実行する際に完全なパスを使用する必要があります。


```
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --unprivileged
```


デフォルトでは `$HOME/gaianet` ディレクトリにインストールされますが、別のディレク

トリにインストールすることもできます。


```
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```



## ノードを初期化

```
gaianet init
```


<details><summary> 出力は以下のようになります: </summary>


```
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

`init` コマンドは、`$HOME/gaianet/config.json` ファイルに従ってノードを初期化します。GaiaNetのドキュメントを知識ベースとして使用するノードを初期化するためのコマンドは以下の通りです。


```
gaianet init --config gaianet_docs
```


プリセット設定のリストを見るには、`gaianet init --help` を実行できます。
`gaianet_docs`のようなプリセット設定の他に、ノードが希望する状態に初期化されるように自分の `config.json` のURLを渡すこともできます。

別のディレクトリにインストールされたノードを初期化するには、以下を実行します。


```
gaianet init --base $HOME/gaianet.alt
```



## ノードを開始

```
gaianet start
```


<details><summary> 出力は以下のようになります: </summary>


```
[+] Starting Qdrant instance ...

    Qdrant instance started with pid: 39762

[+] Starting LlamaEdge API Server ...

    Run the following command to start the LlamaEdge API Server:

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"


    LlamaEdge API Server started with pid: 39796
```


</details>

ローカルでノードを開始することができます。これは `localhost` 経由でのみアクセス可能で、GaiaNetドメインの公開URLでは利用できません。


```
gaianet start --local-only
```


別のベースディレクトリにインストールされたノードも開始できます。


```
gaianet start --base $HOME/gaianet.alt
```



### ノードを停止

```
gaianet stop
```


<details><summary> 出力は以下のようになります: </summary>


```
[+] Stopping WasmEdge, Qdrant and frpc ...
```


</details>

別のベースディレクトリにインストールされたノードを停止します。


```
gaianet stop --base $HOME/gaianet.alt
```



### 設定を更新

`gaianet config` サブコマンドを使用して、`config.json` ファイルで定義された主要なフィールドを更新できます。設定を更新した後は、`gaianet init` を再実行する必要があります。

たとえば、`chat` フィールドを更新するには、次のコマンドを使用します：


```
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```


たとえば、`chat_ctx_size` フィールドを更新するには、次のコマンドを使用します：


```
gaianet config --chat-ctx-size 5120
```


`config` サブコマンドのすべてのオプションは以下の通りです。


```
$ gaianet config --help

使用方法: gaianet config [OPTIONS]

オプション:
  --chat-url <url>               チャットモデルのURLを更新。
  --chat-ctx-size <val>          チャットモデルのコンテキストサイズを更新。
  --embedding-url <url>          埋め込みモデルのURLを更新。
  --embedding-ctx-size <val>     埋め込みモデルのコンテキストサイズを更新。
  --prompt-template <val>        チャットモデルのプロンプトテンプレートを更新。
  --port <val>                   LlamaEdge APIサーバーのポートを更新。
  --system-prompt <val>          システムプロンプトを更新。
  --rag-prompt <val>             RAGプロンプトを更新。
  --rag-policy <val>             RAGポリシーを更新 [可能な値: system-message, last-user-message].
  --reverse-prompt <val>         逆プロンプトを更新。
  --domain <val>                 GaiaNetノードのドメインを更新。
  --snapshot <url>               Qdrantスナップショットを更新。
  --qdrant-limit <val>           返す結果の最大数を更新。
  --qdrant-score-threshold <val> 結果の最小スコア閾値を更新。
  --base <path>                  GaiaNetノードのベースディレクトリ。
  --help                         このヘルプメッセージを表示
```


楽しんでください！
