# MENJALANKAN GAIA NODE MILIK ANDA


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

## MULAI DENGAN CEPAT

Instal kumpulan perangkat lunak *node* bawaan hanya dengan menggunakan satu baris perintah di Mac, Linux, atau Windows WSL.

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

Kemudian, ikuti perintah yang muncul pada layar Anda untuk menyiapkan *environment path*. yang dimulai dengan mengetikkan `source`, contohnya adalah `source ~/.bashrc`.

Inisialisasi *node*. Ini akan mengunduh file model dan file basis data vektor yang ditentukan sesuai pada file `$HOME/gaianet/config.json`, dan mungkin memerlukan waktu beberapa menit karena file berukuran besar.

```bash
gaianet init
```

Mulai node dengan perintah

```bash
gaianet start
```

*Script* akan memunculkan alamat dari *node* pada *console*. Anda dapat melakukan klik pada link tersebut untuk membuka browser dan melihat informasi *node* beserta memulai obrolan dengan agen AI dari *node* tersebut.

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

Untuk menghentikan *node*, anda bisa menjalankan perintah berikut.

```bash
gaianet stop
```

## Panduan Instalasi

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary> Hasilnya seharusnya akan seperti dibawah ini: </summary>

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

Secara bawaan, ini diinstal ke direktori `$HOME/gaianet`. Namun anda juga dapat memilih untuk menginstal ke direktori alternatif.

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## Inisialisasi node

```
gaianet init
```

<details><summary> Hasilnya seharusnya akan seperti dibawah ini: </summary>

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

Perintah `init` menginisialisasi *node* sesuai dengan file `$HOME/gaianet/config.json`. Anda dapat menggunakan beberapa konfigurasi standar. Misalnya, perintah di bawah ini menginisialisasi *node* dengan model llama-3 8B dengan buku panduan London sebagai basis pengetahuan.

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json
```

Untuk melihat daftar konfigurasi yang telah ditentukan sebelumnya, Anda dapat menjalankan perintah `gaianet init --help`.
Selain konfigurasi yang telah ditentukan sebelumnya seperti `gaianet_docs`, Anda juga dapat meneruskan URL ke `config.json` Anda sendiri agar *node* dapat diinisialisasi sesuai dengan kondisi yang Anda inginkan.

Jika Anda perlu `init` sebuah *node* yang diinstal di direktori alternatif, lakukan ini.

```bash
gaianet init --base $HOME/gaianet.alt
```

## Memulai Menjalankan Node

```
gaianet start
```

<details><summary> Hasilnya seharusnya akan seperti dibawah ini: </summary>

```bash
[+] Starting Qdrant instance ...

    Qdrant instance started with pid: 39762

[+] Starting LlamaEdge API Server ...

    Run the following command to start the LlamaEdge API Server:

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"


    LlamaEdge API Server started with pid: 39796
```

</details>

You can start the *node* for local use. It will be only accessible via `localhost` and not available on any of the GaiaNet domain's public URLs.
Anda dapat memulai *node* untuk penggunaan lokal. Dengan ini *node* hanya dapat diakses melalui `localhost` dan tidak tersedia di URL publik domain GaiaNet mana pun.

```bash
gaianet start --local-only
```

Anda juga dapat memulai sebuah *node* yang diinstal di direktori alternatif.

```bash
gaianet start --base $HOME/gaianet.alt
```

### Menghentikan Node

```bash
gaianet stop
```

<details><summary> Hasilnya seharusnya akan seperti dibawah ini: </summary>

```bash
[+] Stopping WasmEdge, Qdrant and frpc ...
```

</details>

Berikut ini adalah perintah jika anda ingin menghentikan *node* yang terinstall di direktori alternatif.

```bash
gaianet stop --base $HOME/gaianet.alt
```

### Update configuration

Menggunakan subperintah `gaianet config` dapat memperbarui bidang kunci yang ditentukan dalam file `config.json`. Anda HARUS menjalankan `gaianet init` lagi setelah Anda memperbarui konfigurasi.

Untuk memperbarui kolom `chat`, misalnya, gunakan perintah berikut:

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```

Untuk memperbarui kolom `chat_ctx_size`, misalnya, gunakan perintah berikut:

```bash
gaianet config --chat-ctx-size 5120
```

Di bawah ini adalah semua opsi subperintah `config`.

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

Selamat Bersenang-senang!
