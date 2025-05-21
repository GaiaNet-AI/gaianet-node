# Запустите собственный узел GaiaNet

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

[Japanese(日本語)](README-ja.md) | [Chinese(中文)](README-cn.md) | [Korean(한국어)](README-kr.md) | [Turkish (Türkçe)](README-tr.md) | [Farsi(فارسی)](README-fa.md) | [Arabic (العربية)](README-ar.md) | [Indonesia](README-id.md) | [Russian (русскийة)](README-ru.md) | [Portuguese (português)](README-pt.md) | Нам нужна ваша помощь в переводе этого README на ваш родной язык.

Если вам нравится наша работа — ⭐ поставьте звезду!

Ознакомьтесь с нашими [официальными документациями](https://docs.gaianet.ai/) и [электронной книгой Manning](https://www.manning.com/liveprojectseries/open-source-llms-on-your-own-computer) о том, как настраивать открытые модели.

---

## Быстрый старт

Установите стандартный программный стек узла одной командой на Mac, Linux или Windows WSL.

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

> Затем следуйте подсказкам на экране для настройки переменной окружения PATH. Команда начнётся с `source`.

![image](https://github.com/user-attachments/assets/dc75817c-9a54-4994-ab90-1efb1a018b17)

Инициализируйте узел. Он загрузит файлы модели и файлы векторной базы данных, указанные в файле `$HOME/gaianet/config.json`. Поскольку файлы большие, процесс может занять несколько минут.

```bash
gaianet init
```

Запустите узел.

```bash
gaianet start
```

После запуска в консоли появится официальный адрес узла, например:
Вы можете открыть этот URL в браузере, чтобы просмотреть информацию об узле и начать чат с ИИ-агентом на узле.

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

Для остановки узла выполните:

```bash
gaianet stop
```

## Руководство по установке

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary>Пример вывода: </summary>

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

По умолчанию установка происходит в каталог `$HOME/gaianet`. Вы можете указать другой каталог для установки:

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## Инициализация узла

```
gaianet init
```

<details><summary>Пример вывода:</summary>

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

Команда `init` инициализирует узел согласно настройкам из файла `$HOME/gaianet/config.json`. Вы можете использовать готовые конфигурации. Например, следующая команда инициализирует узел с моделью llama-3 8B и лондонским путеводителем в качестве базы знаний.

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json
```

Чтобы посмотреть список готовых конфигураций, используйте: `gaianet init --help`
Помимо готовых конфигураций, таких как `gaianet_docs`, вы можете передать URL собственного файла `config.json` для инициализации узла с нужными вам настройками.

Если узел установлен в альтернативном каталоге, инициализируйте его так:

```bash
gaianet init --base $HOME/gaianet.alt
```

## Запуск узла

```
gaianet start
```

<details><summary>Пример вывода:</summary>

```bash
[+] Starting Qdrant instance ...

    Qdrant instance started with pid: 39762

[+] Starting LlamaEdge API Server ...

    Run the following command to start the LlamaEdge API Server:

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"


    LlamaEdge API Server started with pid: 39796
```

</details>

Вы можете запустить узел только для локального использования — тогда он будет доступен только через `localhost` и не будет доступен через публичные URL-адреса GaiaNet.

```bash
gaianet start --local-only
```

Для запуска узла из альтернативного каталога:

```bash
gaianet start --base $HOME/gaianet.alt
```

### Остановка узла

```bash
gaianet stop
```

<details><summary>Пример вывода:</summary>

```bash
[+] Stopping WasmEdge, Qdrant and frpc ...
```

</details>

Остановка узла из альтернативного каталога:

```bash
gaianet stop --base $HOME/gaianet.alt
```

### Обновление конфигурации

С помощью подкоманды `gaianet config` вы можете обновлять ключевые параметры в файле `config.json`. После изменения конфигурации обязательно выполните `gaianet init` заново.

Пример обновления URL модели чата:

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```

Пример обновления размера контекста модели чата:

```bash
gaianet config --chat-ctx-size 5120
```

Все доступные опции подкоманды `config`:

```console
$ gaianet config --help

Usage: gaianet config [OPTIONS]

Options:
  --chat-url <url>               Обновить URL модели чата.
  --chat-ctx-size <val>          Обновить размер контекста модели чата.
  --embedding-url <url>          Обновить URL модели эмбеддингов.
  --embedding-ctx-size <val>     Обновить размер контекста модели эмбеддингов.
  --prompt-template <val>        Обновить шаблон подсказки модели чата.
  --port <val>                   Обновить порт LlamaEdge API Server.
  --system-prompt <val>          Обновить системную подсказку.
  --rag-prompt <val>             Обновить rag-подсказку.
  --rag-policy <val>             Обновить политику rag [Возможные значения: system-message, last-user-message].
  --reverse-prompt <val>         Обновить обратную подсказку.
  --domain <val>                 Обновить домен узла GaiaNet.
  --snapshot <url>               Обновить снимок Qdrant.
  --qdrant-limit <val>           Обновить максимальное число возвращаемых результатов.
  --qdrant-score-threshold <val> Обновить минимальный порог оценки для результата.
  --base <path>                  Базовый каталог узла GaiaNet.
  --help                         Показать это сообщение помощи.
```

Приятного использования!

## Ресурсы и вклад в проект

Ищете документацию? Ознакомьтесь с [официальной документацией](https://docs.gaianet.ai/intro) и [руководством по участию](https://github.com/Gaianet-AI/gaianet-node/blob/main/.github/CONTRIBUTING.md). Рекомендуем также посмотреть [Awesome-Gaia](https://github.com/GaiaNet-AI/awesome-gaia) — список полезных инструментов и проектов сообщества Gaia.

Хотите пообщаться с сообществом? Присоединяйтесь к нашему Telegram чату [Telegram](https://t.me/+a0bJInD5lsYxNDJl) и делитесь идеями и своими разработками на базе GaiaNet.

Нашли ошибку? Загляните в [трекер задач](https://github.com/GaiaNet-AI/gaianet-node/issues), мы постараемся помочь. Мы также рады pull request'ам!

Все участники GaiaNet обязаны соблюдать [Кодекс поведения](https://github.com/Gaianet-AI/gaianet-node/blob/main/.github/CODE_OF_CONDUCT.md).

[**→ Начать вносить вклад на GitHub**](https://github.com/Gaianet-AI/gaianet-node/blob/main/.github/CONTRIBUTING.md)

### Участники проекта

<a href="https://github.com/GaiaNet-AI/gaianet-node/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=GaiaNet-AI/gaianet-node" alt="Gaia project contributors" />
</a>
