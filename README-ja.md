# 自分のGaiaNetノードを起動する

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

[Japanese(日本語)](README-ja.md) | [Chinese(中文)](README-cn.md) | [Korean(한국어)](README-kr.md) | [Turkish (Türkçe)](README-tr.md) | [Farsi(فارسی)](README-fa.md) | [Arabic (العربية)](README-ar.md) | [Indonesia](README-id.md) | [Russian (русскийة)](README-ru.md) | [Portuguese (português)](README-pt.md) | このREADMEをあなたの母国語に翻訳するのを手伝ってください。

私たちの活動が気に入りましたか？⭐スターしてください！

[公式ドキュメント](https://docs.gaianet.ai/) や、オープンソースモデルをカスタマイズする方法についての [Manning電子書籍](https://www.manning.com/liveprojectseries/open-source-llms-on-your-own-computer) をチェックしてください。

---

## クイックスタート

Mac、Linux、またはWindows WSLで、以下のコマンド1行でデフォルトのノードソフトウェアスタックをインストールします。

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

> その後、画面の指示に従って環境パスを設定してください。`source`から始まるコマンドラインが表示されます。

![image](https://github.com/user-attachments/assets/dc75817c-9a54-4994-ab90-1efb1a018b17)

ノードを初期化します。これは、`$HOME/gaianet/config.json` ファイルで指定されたモデルファイルとベクターデータベースファイルをダウンロードします。ファイルサイズが大きいため、数分かかる場合があります。

```bash
gaianet init
```

ノードを起動します。

```bash
gaianet start
```

スクリプトは以下のように公式ノードアドレスをコンソールに表示します。
ブラウザでそのURLを開くとノード情報を確認でき、AIエージェントと対話できます。

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

ノードを停止するには、以下のスクリプトを実行します。

```bash
gaianet stop
```

（以下省略。全体は非常に長いため、前メッセージをご参照ください）

## インストールガイド


GaiaNet ノードは以下のコマンドでインストールできます:

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details>
<summary>出力例</summary>

```console
[+] デフォルト設定ファイルをダウンロード中...

[+] nodeid.json をダウンロード中...

[+] WasmEdgeをwasi-nn_ggmlプラグイン付きでインストール中...

情報: Linux-x86_64を検出

情報: WasmEdgeは /home/azureuser/.wasmedge にインストール

情報: WasmEdge-0.13.5を取得中

/tmp/wasmedge.2884467 ~/gaianet
######################################################################## 100.0%
~/gaianet
情報: WasmEdge-GGML-Pluginを取得中

情報: CUDAバージョンを検出:

/tmp/wasmedge.2884467 ~/gaianet
######################################################################## 100.0%
~/gaianet
wasmedge-0.13.5のインストール成功
WasmEdgeバイナリは利用可能

    WasmEdgeランタイム wasmedge バージョン0.13.5が /home/azureuser/.wasmedge/bin/wasmedge にインストールされました。

[+] Qdrantバイナリをインストール中...
    * Qdrantバイナリをダウンロード中
################################################################################################## 100.0%

    * Qdrantディレクトリを初期化

[+] rag-api-server.wasmをダウンロード中...
################################################################################################## 100.0%

[+] ダッシュボードをダウンロード中...
################################################################################################## 100.0%
```

</details>

> 💡 デフォルトでは `$HOME/gaianet` にインストールされます。

別のディレクトリにインストールしたい場合は、次のように指定します:

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

---

## ノードの初期化

インストール後、ノードを初期化するには以下のコマンドを実行します:

```bash
gaianet init
```

<details>
<summary>出力例</summary>

```console
[+] Llama-2-7b-chat-hf-Q5_K_M.gguf をダウンロード中...
############################################################################################################################## 100.0%

[+] all-MiniLM-L6-v2-ggml-model-f16.gguf をダウンロード中...
############################################################################################################################## 100.0%

[+] Qdrantインスタンスに「default」コレクションを作成中...

    * Qdrantインスタンスを起動中...

    * 既存の「default」Qdrantコレクションを削除中...

    * Qdrantコレクションのスナップショットをダウンロード中...
############################################################################################################################## 100.0%

    * Qdrantコレクションスナップショットをインポート中...

    * リカバリが成功しました
```

</details>


`init` コマンドは、`$HOME/gaianet/config.json` ファイルに従ってノードを初期化します。プリセット設定もいくつか使用できます。例えば、以下のコマンドは、ロンドンガイドブックを知識ベースとして、llama-3 8B モデルでノードを初期化します。

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json
```

利用可能な構成リストは、以下のコマンドで確認できます:

```bash
gaianet init --help
```

自分の `config.json` を指定した URL 経由で渡すことも可能です。


別ディレクトリにインストールしたノードを初期化する場合は以下のようにします:

```bash
gaianet init --base $HOME/gaianet.alt
```


## ノードの起動


```bash
gaianet start
```

<details>
<summary>出力例は以下の通りです：</summary>

```bash
[+] Qdrantインスタンスを起動中...

    Qdrantインスタンスは pid: 39762 で起動しました

[+] LlamaEdge APIサーバーを起動中...

    LlamaEdge APIサーバーを起動するには以下のコマンドを実行：

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"

    LlamaEdge APIサーバーは pid: 39796 で起動しました
```

</details>

ローカルでノードを起動するには:

```bash
gaianet start --local-only
```

別ディレクトリにインストールされたノードを起動するには:

```bash
gaianet start --base $HOME/gaianet.alt
```

---

### ノードの停止

```bash
gaianet stop
```

<details>
<summary>出力例は以下の通りです：</summary>

```bash
[+] WasmEdge、Qdrant、frpc を停止中...
```

</details>

別のベースディレクトリにインストールされたノードを停止するには:

```bash
gaianet stop --base $HOME/gaianet.alt
```

---

### 設定の更新

`gaianet config` サブコマンドを使用して `config.json` に定義された主要フィールドを更新できます。  
設定を変更した後は必ず `gaianet init` を再実行してください。

例: `chat` フィールドを更新する

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```

例: `chat_ctx_size` フィールドを更新する

```bash
gaianet config --chat-ctx-size 5120
```

以下は `config` サブコマンドのすべてのオプションです。

```console
$ gaianet config --help

使用法: gaianet config [OPTIONS]

オプション:
  --chat-url <url>               チャットモデルのURLを更新
  --chat-ctx-size <val>          チャットモデルのコンテキストサイズを更新
  --embedding-url <url>          埋め込みモデルのURLを更新
  --embedding-ctx-size <val>     埋め込みモデルのコンテキストサイズを更新
  --prompt-template <val>        チャットモデルのプロンプトテンプレートを更新
  --port <val>                   LlamaEdge APIサーバーのポートを更新
  --system-prompt <val>          システムプロンプトを更新
  --rag-prompt <val>             RAGプロンプトを更新
  --rag-policy <val>             RAGポリシーを更新 [可能な値: system-message, last-user-message]
  --reverse-prompt <val>         逆プロンプトを更新
  --domain <val>                 GaiaNetノードのドメインを更新
  --snapshot <url>               Qdrantスナップショットを更新
  --qdrant-limit <val>           結果の最大件数を更新
  --qdrant-score-threshold <val> 最小スコア閾値を更新
  --base <path>                  GaiaNetノードのベースディレクトリ
  --help                         このヘルプメッセージを表示
```

---

 楽しんでください！

## リソース & コミュニティへの貢献

- ドキュメントをお探しですか？ [ドキュメント](https://github.com/GaiaNet-AI/gaianet-node#readme) または [貢献ガイド](https://github.com/GaiaNet-AI/gaianet-node/blob/main/CONTRIBUTING.md) をご覧ください。
- Gaia コミュニティからのツールやプロジェクトのキュレーションリストは [Awesome-Gaia](https://github.com/GaiaNet-AI/awesome-gaia) をチェック！
- コミュニティと話したい？ [Telegram](https://t.me/gaianet_ai) に参加して、アイデアや作成したプロジェクトを共有しましょう。
- バグを見つけましたか？ [Issue トラッカー](https://github.com/GaiaNet-AI/gaianet-node/issues) にアクセスしてください。プルリクエストも大歓迎です！

すべての Gaianet の貢献者は [行動規範](https://github.com/GaiaNet-AI/gaianet-node/blob/main/CODE_OF_CONDUCT.md) に従う必要があります。

👉 [GitHubで貢献を始める](https://github.com/GaiaNet-AI/gaianet-node)

---

### コントリビューター

<a href="https://github.com/GaiaNet-AI/gaianet-node/graphs/contributors">
<img src="https://contrib.rocks/image?repo=GaiaNet-AI/gaianet-node" alt="Gaia プロジェクトの貢献者" />
</a>
