
# اجرای نود GaiaNet خودتان

  
  
  

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

  
  

[Japanese(日本語)](README-ja.md) | [Chinese(中文)](README-cn.md) | [Turkish (Türkçe)](README-tr.md) | [Farsi(فارسی)](README-fa.md) | 

ما به کمک شما برای ترجمه این 
README
به زبان مادری‌تان نیاز داریم.

  

از کار ما خوشتان آمده؟ ⭐ ما را ستاره‌دار کنید!

  

---

  

## شروع سریع

 نصب نرم‌افزار پیش‌فرض نود با یک خط دستور در مک، لینوکس، یا ویندوز (WSL).

  

```bash

curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash

```

سپس، از دستورات روی صفحه برای تنظیم environment path پیروی کنید. خط فرمان با `source` شروع خواهد شد.

  

نود را مقداردهی اولیه کنید. این کار فایل‌های مدل و فایل‌های پایگاه داده وکتور که در فایل `HOME/gaianet/config.json$` مشخص شده‌اند را دانلود می‌کند و ممکن است چند دقیقه طول بکشد زیرا فایل‌ها بزرگ هستند.

  
```bash

gaianet init

```


نود را شروع کنید

```bash

gaianet start

```
  

اسکریپت، آدرس رسمی نود را در کنسول چاپ می‌کند به صورت زیر. می‌توانید  آن URL را در مرورگری باز کنید تا اطلاعات نود را ببینید و سپس با هوش مصنوعی در نود چت کنید.  
  

```

... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network

```
  

برای توقف نود، می‌توانید اسکریپت زیر را اجرا کنید.

  

```bash

gaianet stop

```

  

## راهنمای نصب

  

```bash

curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash

```

  

<details dir="rtl"><summary> خروجی باید به صورت زیر باشد: </summary>  

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

  

به‌طور پیش‌فرض، در دایرکتوری `HOME/gaianet$` نصب می‌شود. همچنین می‌توانید انتخاب کنید که در دایرکتوری دیگری نصب شود.
  

```bash

curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt

```
  

## مقداردهی اولیه نود

  

```

gaianet init

```

  

<details dir="rtl"><summary> خروجی باید به صورت زیر باشد : </summary>


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

  

دستور `init` نود را بر اساس فایل `HOME/gaianet/config.json$` مقداردهی اولیه می‌کند. شما می‌توانید از برخی از پیکربندی‌های از پیش تنظیم شده ما استفاده کنید. به عنوان مثال، دستور زیر نود را با مدل    llama-3 8B و  راهنمای London guidebook به عنوان پایگاه دانش مقداردهی اولیه می‌کند.

  

```bash

gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json

```

  

برای دیدن لیست پیکربندی‌های از پیش تنظیم شده، می‌توانید `gaianet init --help` را اجرا کنید. علاوه بر پیکربندی‌های از پیش تنظیم شده مانند `gaianet_docs`، می‌توانید یک URL به فایل `config.json` خودتان بدهید تا نود را به حالت دلخواهتان مقداردهی اولیه کنید.

  

اگر نیاز به `init` نود نصب شده در دایرکتوری دیگری دارید، این کار را انجام دهید.

  

```bash

gaianet init --base $HOME/gaianet.alt

```

  

## شروع نود

  

```

gaianet start

```

  

<details dir="rtl"><summary> خروجی باید به صورت زیر باشد: </summary>

  

```bash

[+] Starting Qdrant instance ...

  

    Qdrant instance started with pid: 39762

  

[+] Starting LlamaEdge API Server ...

  

    Run the following command to start the LlamaEdge API Server:

  

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"

  
  

    LlamaEdge API Server started with pid: 39796

```

  

</details>

 میتوانید نود را برای استفاده local شروع کنید. این نود فقط از طریق `localhost` قابل دسترسی خواهد بود و در هیچ یک از URL های عمومی دامنه GaiaNet در دسترس نخواهد بود.

  

```bash

gaianet start --local-only

```

  

می‌توانید نود نصب شده در یک دایرکتوری base جایگزین را نیز شروع کنید.

  

```bash

gaianet start --base $HOME/gaianet.alt

```

  

### توقف نود

  

```bash

gaianet stop

```

  

<details dir="rtl"><summary> خروجی باید به صورت زیر باشد : </summary>

  

```bash

[+] Stopping WasmEdge, Qdrant and frpc ...

```

  

</details>

  

نود نصب شده در یک دایرکتوری base جایگزین را متوقف کنید.

  

```bash

gaianet stop --base $HOME/gaianet.alt

```

  

### به‌روزرسانی پیکربندی

  

با استفاده از زیر فرمان `gaianet config` می‌توانید فیلدهای کلیدی تعریف شده در فایل `config.json` را به‌روزرسانی کنید. شما باید پس از به‌روزرسانی پیکربندی، دوباره `gaianet init` را اجرا کنید.

  

به عنوان مثال برای به‌روزرسانی فیلد `chat`، از فرمان زیر استفاده کنید:
  

```bash

gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"

```

  

به عنوان مثال برای به‌روزرسانی فیلد `chat_ctx_size`، از فرمان زیر استفاده کنید:

  

```bash

gaianet config --chat-ctx-size 5120

```

  

گزینه‌های زیر فرمان `config` به شرح زیر است:

  

```console

$ gaianet config --help

  

Usage: gaianet config [OPTIONS]

  

Options:

  --chat-url <url>               Update the url of chat model.

  --chat-ctx-size <val>          Update the context size of chat model.

  --embedding-url <url>          Update the url of embedding model.

  --embedding-ctx-size <val>     Update the context size of embedding model.

  --prompt-template <val>        Update the prompt template of chat model.

  --port <val>                   Update the port of LlamaEdge API Server.

  --system-prompt <val>          Update the system prompt.

  --rag-prompt <val>             Update the rag prompt.

  --rag-policy <val>             Update the rag policy [Possible values: system-message, last-user-message].

  --reverse-prompt <val>         Update the reverse prompt.

  --domain <val>                 Update the domain of GaiaNet node.

  --snapshot <url>               Update the Qdrant snapshot.

  --qdrant-limit <val>           Update the max number of result to return.

  --qdrant-score-threshold <val> Update the minimal score threshold for the result.

  --base <path>                  The base directory of GaiaNet node.

  --help                         Show this help message

```

  

لذت ببرید!

