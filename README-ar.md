# قم بتشغيل عقدة Gaianet الخاصة بك


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



[اليابانية(日本語)](README-ja.md) | [الصينية(中文)](README-cn.md) | [التركية (Türkçe)](README-tr.md) | [العربية (العَرَبية)](README-ar.md) | نحتاجُ الى مساعدتك في ترجمة  هذا الملف الى لغتك الأم.


أعجَبَك عَمَلُنا؟ ⭐ قَيْمِنّا بنجمة!
---

## بداية سريعة

قم بتثبيت حزمة برامج العقدة الافتراضية باستخدام أمر واحد على نظام التشغيل Mac أو Linux أو Windows WSL.

```curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

ثم اتبع التعليمات على شاشتك لإعداد مسار البيئة, سيبدأ سطر الأوامر بالأمر `source`.

قم بتهيئة العقدة. ستقوم بتنزيل ملفات النماذج وقواعد بيانات المتجهات المحددة في ملف `$HOME/gaianet/config.json`، وقد يستغرق ذلك بضع دقائق نظرًا لحجم الملفات الكبير.

```bash
gaianet init
```

ابدأ العقدة.

```bash
gaianet start
```
سيقوم النص بطباعة عنوان العقدة الرسمي على الكونسول كما يلي.
يمكنك فتح المتصفح على ذلك العنوان لرؤية معلومات العقدة ثم التحدث مع وكيل الذكاء الاصطناعي على العقدة.

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

لإيقاف العقدة, يمكنك تشغيل الأمر الآتي:

```bash
gaianet stop
```

## دليل التثبيت

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary> يجب أن تبدو النتائج كما يلي: </summary>

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

بشكل افتراضي, يتم التثبيت ب `$HOME/gaianet`, يمكنك أيضًا أن تختارَ عنوانًا بديلاً.

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## تهيئة العقدة

```
gaianet init
```

<details><summary> يجب أن تبدو النتيجة كما يلي: </summary>

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

يعمل أمر `init` على تهيئة العقدة وفقًا لملف `$HOME/gaianet/config.json`. يمكنك استخدام بعض التكوينات المعدة مسبقًا. على سبيل المثال، الأمر أدناه يقوم بتهيئة عقدة باستخدام نموذج llama-3 8B مع دليل لندن كقاعدة معرفية.

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json
```

لرؤية قائمة تكوينات معدة مسبقًا, بإمكانك تشغيل `gaianet init --help`.
بالإضافة إلى التكوينات المعدة مسبقًا مثل `gaianet_docs`، يمكنك أيضًا تمرير عنوان URL إلى ملف `config.json` الخاص بك ليتم تهيئة العقدة بالحالة التي ترغب فيها.


إذا كنت بحاجة إلى تهيئة-`init`- عقدة مثبتة في دليل بديل، قم بذلك على النحو التالي.

```bash
gaianet init --base $HOME/gaianet.alt
```

## إبدأ العقدة

```
gaianet start
```

<details><summary> النتيجة يجب أن تكون كما يلي: </summary>

```bash
[+] Starting Qdrant instance ...

    Qdrant instance started with pid: 39762

[+] Starting LlamaEdge API Server ...

    Run the following command to start the LlamaEdge API Server:

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"


    LlamaEdge API Server started with pid: 39796
```

</details>

يمكنك بدء العقدة للاستخدام المحلي. ستكون متاحة فقط عبر `localhost` ولن تكون متاحة على أي من عناوين URL العامة لنطاقات GaiaNet.

```bash
gaianet start --local-only
```

يمكنك أيضًا بدء عقدة مثبتة في دليل أساسي بديل.

```bash
gaianet start --base $HOME/gaianet.alt
```

### أوقف العقدة

```bash
gaianet stop
```

<details><summary> النتيجة يجب أن تبدو كما يلي: </summary>

```bash
[+] Stopping WasmEdge, Qdrant and frpc ...
```

</details>

إيقاف عقدة مثبتة في دليل أساسي بديل.

```bash
gaianet stop --base $HOME/gaianet.alt
```

### تحديث التكوين

باستخدام الأمر الفرعي `gaianet config` يمكنك تحديث الحقول الأساسية المحددة في ملف `config.json`. **يجب** عليك تشغيل `gaianet init` مرة أخرى بعد تحديث التكوين.



لتحديث حقل `chat`، على سبيل المثال، استخدم الأمر التالي:

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```

لتحديث حقل `chat_ctx_size`، على سبيل المثال، استخدم الأمر التالي:

```bash
gaianet config --chat-ctx-size 5120
```

فيما يلي جميع خيارات الأمر الفرعي `config`:

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

استمتع!
