
# Запустите свой собственный узел GaiaNet

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

[Русский (Русский)](README-ru.md) [Японский(日本語)](README-ja.md) | [Китайский(中文)](README-cn.md) | [Турецкий (Türkçe)](README-tr.md) | Нам нужна ваша помощь в переводе этого README на ваш родной язык.

Нравится наша работа? ⭐ Оцените нас!

---

## Быстрый старт

Установите стандартный программный стек узла с одной строкой команды на Mac, Linux или Windows WSL.

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

Затем следуйте инструкциям на экране для настройки пути окружения. Командная строка начнется с `source`.

Инициализируйте узел. Он загрузит файлы модели и файлы векторной базы данных, указанные в файле `$HOME/gaianet/config.json`, и это может занять несколько минут, так как файлы большие.

```bash
gaianet init
```

Запустите узел.

```bash
gaianet start
```

Скрипт выведет официальный адрес узла на консоль, как показано ниже.
Вы можете открыть браузер по этому URL, чтобы увидеть информацию об узле, а затем общаться с ИИ-агентом на узле.

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

Чтобы остановить узел, вы можете выполнить следующий скрипт.

```bash
gaianet stop
```

## Руководство по установке

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary> Вывод должен выглядеть следующим образом: </summary>

```console
[+] Downloading default config file ...

[+] Downloading nodeid.json ...

<<OutputTruncated>>n
```bash
[+] Stopping WasmEdge, Qdrant and frpc ...
```

</details>

Остановите узел, установленный в альтернативном базовом каталоге.

```bash
gaianet stop --base $HOME/gaianet.alt
```

### Обновление конфигурации

Использование подкоманды `gaianet config` может обновить ключевые поля, определенные в файле `config.json`. Вы ДОЛЖНЫ снова выполнить команду `gaianet init` после обновления конфигурации.

Чтобы обновить поле `chat`, например, используйте следующую команду:

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```

Чтобы обновить поле `chat_ctx_size`, например, используйте следующую команду:

```bash
gaianet config --chat-ctx-size 5120
```

Ниже приведены все опции подкоманды `config`.

```console
$ gaianet config --help

Usage: gaianet config [OPTIONS]

Options:
  --chat-url <url>               Обновить URL модели чата.
  --chat-ctx-size <val>          Обновить размер контекста модели чата.
  --embedding-url <url>          Обновить URL модели встраивания.
  --embedding-ctx-size <val>     Обновить размер контекста модели встраивания.
  --prompt-template <val>        Обновить шаблон подсказки модели чата.
  --port <val>                   Обновить порт LlamaEdge API Server.
  --system-prompt <val>          Обновить системную подсказку.
  --rag-prompt <val>             Обновить RAG-подсказку.
  --rag-policy <val>             Обновить политику RAG [Возможные значения: system-message, last-user-message].
  --reverse-prompt <val>         Обновить обратную подсказку.
  --domain <val>                 Обновить домен узла GaiaNet.
  --snapshot <url>               Обновить снимок Qdrant.
  --qdrant-limit <val>           Обновить максимальное количество возвращаемых результатов.
  --qdrant-score-threshold <val> Обновить минимальный порог оценки для результата.
  --base <path>                  Базовый каталог узла GaiaNet.
  --help                         Показать это справочное сообщение
```

Удачи!
