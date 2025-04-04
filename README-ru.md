# Запуск ноды GaiaNet

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

[Japanese(日本語)](README-ja.md) | [Chinese(中文)](README-cn.md) | [Turkish (Türkçe)](README-tr.md) | [Arabic (العربية)](README-ar.md) | [Russian (русский)](README-ru.md) | Нам нужна ваша помощь, чтобы перевести этот README на ваш родной язык.

Нравится наша работа? ⭐ Поставьте нам звезду!

---

## Быстрый старт

Установите стандартный стек программного обеспечения узла с помощью одной строки команды на Mac, Linux или Windows WSL.

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

Затем, следуя подсказкам на экране, установите путь к окружению. Командная строка будет начинаться с `source`.

Инициализируйте узел. Он загрузит файлы модели и векторную базу данных, указанные в файле `$HOME/gaianet/config.json`, это может занять некоторое время, поскольку файлы имеют большой размер.

```bash
gaianet init
```

Запустите узел.

```bash
gaianet start
```

Скрипт выводит в консоль официальный адрес узла следующим образом.
Вы можете открыть браузер по этому URL, чтобы увидеть информацию об узле, а затем пообщаться с агентом ИИ на узле.

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

Чтобы остановить узел, можно запустить следующий скрипт.

```bash
gaianet stop
```

## Руководство по установке

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary>Вывод должен выглядеть следующим образом: </summary>


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

</details

По умолчанию установка производится в директорию `$HOME/gaianet`. Вы также можете выбрать установку в альтернативный каталог.

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## Инициализация узла

```
gaianet init
````

<details><summary>Вывод должен выглядеть следующим образом: </summary>

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

</details

Команда `init` инициализирует узел в соответствии с файлом `$HOME/gaianet/config.json`. Вы можете использовать некоторые из наших предустановленных конфигураций. Например, команда ниже инициализирует узел с моделью llama-3 8B с путеводителем по Лондону в качестве базы знаний.

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json

```

Чтобы посмотреть список предустановленных конфигураций, вы можете выполнить команду `gaianet init --help`.
Помимо предустановленных конфигураций, таких как `gaianet_docs`, вы также можете передать URL-адрес собственного `config.json`, чтобы узел был инициализирован до нужного вам состояния.

Если вам нужно инициализировать `init` узел, установленный в альтернативной директории, сделайте следующее.

```bash
gaianet init --base $HOME/gaianet.alt
```

## Запуск узла

```bash
gaianet start
```

<details><summary>Вывод должен выглядеть следующим образом: </summary>

```bash
[+] Starting Qdrant instance ...

    Qdrant instance started with pid: 39762

[+] Starting LlamaEdge API Server ...

    Выполните следкющую команду для запуска LlamaEdge API Server:

    wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"


        LlamaEdge API Server started with pid: 39796
    ```

    </details>

    Вы можете запустить узел для локального использования. Он будет доступен только через `localhost` и не будет доступен ни по одному из публичных URL домена GaiaNet.

    ```bash
    gaianet start --local-only
    ```

    Вы также можете запустить узел, установленный в альтернативном базовом каталоге.

    ``bash
    gaianet start --base $HOME/gaianet.alt
    ```

    ### Остановка узла

    ```bash
    gaianet stop
    ```
  <details><summary> Вывод должен выглядеть следующим образом: </summary>

  ```bash
  [+] Stopping WasmEdge, Qdrant and frpc ...
  ```

  </details>

  Остановка узла установленного в альтернативном базовом каталоге.

  ```bash
  gaianet stop --base $HOME/gaianet.alt
  ```

  ### Обновление конфигурации

  Использование подкоманды `gaianet config` позволяет обновить ключевые значения, определенные в файле `config.json`. После обновления конфигурации необходимо снова запустить `gaianet init`.

  Чтобы обновить значение поля `chat`, например, используйте следующую команду:

  ```bash
  gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
  ```

  К примеру, для того чтобы обновить значение поля `chat_ctx_size`, выполните следующую команду:

  ```bash
  gaianet config --chat-ctx-size 5120
  ```
  Ниже перечислены все опции подкоманды `config`.

  ```console
  $ gaianet config --help
  
  Использование: gaianet config [OPTIONS]

  Опции:
    --chat-url <url>               Обновление url модели чата.
    --chat-ctx-size <val>          Обновить размер контекста модели чата.
    --embedding-url <url>          Обновить url модели встраивания.
    --embedding-ctx-size <val>     Обновить размер контекста модели встраивания.
    --prompt-template <val>        Обновить шаблон подсказки модели чата.
    --port <val>                   Обновление порта LlamaEdge API Server.
    --system-prompt <val>          Обновить системную подсказку.
    --rag-prompt <val>             Обновить подсказку rag.
    --rag-policy <val>             Обновление политики rag [Возможные значения: system-message, last-user-message].
    --reverse-prompt <val>         Обновить обратную подсказку.
    --domain <val>                 Обновление домена узла GaiaNet.
    --snapshot <url>               Обновление моментального снимка Qdrant.
    --qdrant-limit <val>           Обновить максимальное количество возвращаемых результатов.
    --qdrant-score-threshold <val> Обновление минимального порога оценки для результата.
    --base <path>                  Базовый каталог узла GaiaNet.
    --help                         Показать сообщение о помощи
  ```
  Удачи!
