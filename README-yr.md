# Ṣe iṣẹ GaiaNet rẹ ni ara ẹni (Yoruba Version)

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

[Japanese(日本語)](README-ja.md) | [Chinese(中文)](README-cn.md) | [Korean(한국어)](README-kr.md) | [Turkish (Türkçe)](README-tr.md) | [Farsi(فارسی)](README-fa.md) | [Arabic (العربية)](README-ar.md) | [Indonesia](README-id.md) | [Russian (русскийة)](README-ru.md) | [Portuguese (português)](README-pt.md) | [Yoruba](README-yo.md) | A n reti iranlọwọ lati tumọ README yi si ede rẹ.

Ṣe o fẹran iṣẹ wa? ⭐ Fi afojuri si wa!

Ṣayẹwo [awọn iwe aṣẹ alaṣẹ](https://docs.gaianet.ai/) ati [iwe Manning](https://www.manning.com/liveprojectseries/open-source-llms-on-your-own-computer) lori bi o ṣe le ṣatunkọ awọn ọna ti o ṣiṣẹ lori ẹrọ ori kọmputa rẹ.

---

## Bẹrẹ ni kiakia

Fi sori ẹrọ ohun elo node ti a fẹsẹtẹ pẹlu ọna iṣẹ kan nikan lori ẹrọ Mac, Linux, tabi Windows WSL.

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

> Lẹhinna, tẹle awọn ilana ti o han lori iwọle rẹ lati ṣeto ọna ayika. Ọna iṣẹ yoo bẹrẹ pẹlu `source`.

![image](https://github.com/user-attachments/assets/dc75817c-9a54-4994-ab90-1efb1a018b17)

Bẹrẹ node naa. Yoo gba awọn faili ọna ati awọn faili database vector ti a ti sọ pataki ninu faili `$HOME/gaianet/config.json`, o si le gba diẹ ninu iṣẹju nitori awọn faili naa tobi.

```bash
gaianet init
```

Bẹrẹ node naa.

```bash
gaianet start
```

Awọn ọna iṣẹ naa yoo tẹ adirẹsi node alaṣẹ lori iwọle bi atẹle.
O le ṣii olupilẹṣẹ si URL naa lati ri alaye node ati lẹhinna bá ọrọ pẹlu aṣoju AI lori node naa.

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

Lati dẹku node naa, o le ṣiṣẹ ọna iṣẹ atẹle.

```bash
gaianet stop
```

## Itọsọna Ifisori ẹrọ

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary> Awọn iṣẹlẹ yẹ ki o dabi atẹle: </summary>

```console
[+] Gbigba faili iṣeto aiyipada ...

[+] Gbigba nodeid.json ...

[+] Nfi WasmEdge sori ẹrọ pẹlu ohun elo wasi-nn_ggml ...

Alaye: Wo Linux-x86_64

Alaye: Ifisori ẹrọ WasmEdge ni /home/azureuser/.wasmedge

Alaye: Nṣe WasmEdge-0.13.5

/tmp/wasmedge.2884467 ~/gaianet
######################################################################## 100.0%
~/gaianet
Alaye: Nṣe WasmEdge-GGML-Plugin

Alaye: Wo ẹya CUDA:

/tmp/wasmedge.2884467 ~/gaianet
######################################################################## 100.0%
~/gaianet
Ifisori ẹrọ wasmedge-0.13.5 ti ṣẹṣẹ
Awọn oniṣẹ WasmEdge le ṣe deede

    WasmEdge Runtime wasmedge ẹya 0.13.5 ti fi sori ẹrọ ni /home/azureuser/.wasmedge/bin/wasmedge.


[+] Nfi Qdrant binary sori ẹrọ...
    * Gba Qdrant binary
################################################################################################## 100.0%

    * Ṣeto akopọ Qdrant

[+] Nṣe gbigba rag-api-server.wasm ...
################################################################################################## 100.0%

[+] Nṣe gbigba dashboard ...
################################################################################################## 100.0%
```

</details>

Ni aiyipada, o n fi sori ẹrọ sinu akopọ `$HOME/gaianet`. O tun le yan lati fi sori ẹrọ sinu akopọ miiran.

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## Ṣeto node naa

```
gaianet init
```

<details><summary> Awọn iṣẹlẹ yẹ ki o dabi atẹle: </summary>

```bash
[+] Nṣe gbigba Llama-2-7b-chat-hf-Q5_K_M.gguf ...
############################################################################################################################## 100.0%############################################################################################################################## 100.0%

[+] Nṣe gbigba all-MiniLM-L6-v2-ggml-model-f16.gguf ...

############################################################################################################################## 100.0%############################################################################################################################## 100.0%

[+] Ṣiṣẹda 'aṣa' akopọ ninu iṣẹ Qdrant ...

    * Bẹrẹ iṣẹ Qdrant ...

    * Yọ 'aṣa' Qdrant akopọ ti wa tẹlẹ ...

    * Gba akopọ Qdrant snapshot ...
############################################################################################################################## 100.0%############################################################################################################################## 100.0%

    * Gbe wọle akopọ Qdrant snapshot ...

    * Atunṣe ti ṣẹṣẹ ni aṣeyọri
```

</details>

Ọna iṣẹ `init` n ṣeto node naa gẹgẹbi faili `$HOME/gaianet/config.json`. O le lo diẹ ninu awọn iṣeto ti a ti ṣeto tẹlẹ. Fun apẹẹrẹ, ọna iṣẹ atẹle n ṣeto node pẹlu ọna llama-3 8B pẹlu iwe itọsọna London bi ipilẹ ọgbọn.

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json
```

Lati wo atokọ awọn iṣeto ti a ti ṣeto tẹlẹ, o le ṣe `gaianet init --help`.
Yato si awọn iṣeto ti a ti ṣeto tẹlẹ bi `gaianet_docs`, o tun le fun URL si `config.json` tirẹ fun node lati ṣeto si ipo ti o fẹ.

Ti o ba nilo lati `init` node ti a fi sori ẹrọ ni akopọ miiran, ṣe eyi.

```bash
gaianet init --base $HOME/gaianet.alt
```

## Bẹrẹ node naa

```
gaianet start
```

<details><summary> Awọn iṣẹlẹ yẹ ki o dabi atẹle: </summary>

```bash
[+] Nṣe bẹrẹ iṣẹ Qdrant ...

    Iṣẹ Qdrant ti bẹrẹ pẹlu pid: 39762

[+] Nṣe bẹrẹ LlamaEdge API Server ...

    Ṣiṣẹ ọna iṣẹ atẹle lati bẹrẹ LlamaEdge API Server:

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"


    LlamaEdge API Server ti bẹrẹ pẹlu pid: 39796
```

</details>

O le bẹrẹ node fun lilo agbegbe nikan. Yoo ṣee deede nipa `localhost` nikan ati ko ṣee ṣe lori eyikeyi awọn URL gbangba ti nẹtiwọọki GaiaNet.

```bash
gaianet start --local-only
```

O tun le bẹrẹ node ti a fi sori ẹrọ ni akopọ ipilẹ miiran.

```bash
gaianet start --base $HOME/gaianet.alt
```

### Dẹku node naa

```bash
gaianet stop
```

<details><summary> Awọn iṣẹlẹ yẹ ki o dabi atẹle: </summary>

```bash
[+] Nṣe dẹku WasmEdge, Qdrant ati frpc ...
```

</details>

Dẹku node ti a fi sori ẹrọ ni akopọ ipilẹ miiran.

```bash
gaianet stop --base $HOME/gaianet.alt
```

### Ṣe imudojuiwọn iṣeto

Lilo `gaianet config` subcommand le ṣe imudojuiwọn awọn aaye pataki ti a ti sọ pataki ninu faili `config.json`. O GBAỌDỌ ṣiṣẹ `gaianet init` lẹẹkansi lẹhin ti o ti ṣe imudojuiwọn iṣeto.

Lati ṣe imudojuiwọn aaye `chat`, fun apẹẹrẹ, lo ọna iṣẹ atẹle:

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```

Lati ṣe imudojuiwọn aaye `chat_ctx_size`, fun apẹẹrẹ, lo ọna iṣẹ atẹle:

```bash
gaianet config --chat-ctx-size 5120
```

Isalẹ ni gbogbo awọn aṣayan `config` subcommand.

```console
$ gaianet config --help

Lilo: gaianet config [AWỌN AṢAYAN]

Awọn aṣayan:
  --chat-url <url>               �e imudojuiwọn url ti ọna chat.
  --chat-ctx-size <val>          Ṣe imudojuiwọn iwọn ọran ti ọna chat.
  --embedding-url <url>          Ṣe imudojuiwọn url ti ọna ifiṣori.
  --embedding-ctx-size <val>     Ṣe imudojuiwọn iwọn ọran ti ọna ifiṣori.
  --prompt-template <val>        Ṣe imudojuiwọn awoṣe iṣoro ti ọna chat.
  --port <val>                   Ṣe imudojuiwọn ibudo ti LlamaEdge API Server.
  --system-prompt <val>          Ṣe imudojuiwọn iṣoro eto.
  --rag-prompt <val>             Ṣe imudojuiwọn iṣoro rag.
  --rag-policy <val>             �e imudojuiwọn ilana rag [Awọn iye ti o ṣee ṣe: system-message, last-user-message].
  --reverse-prompt <val>         Ṣe imudojuiwọn iṣoro idakeji.
  --domain <val>                 Ṣe imudojuiwọn agbegbe ti node GaiaNet.
  --snapshot <url>               Ṣe imudojuiwọn Qdrant snapshot.
  --qdrant-limit <val>           Ṣe imudojuiwọn iye to pọ julọ ti esi lati da pada.
  --qdrant-score-threshold <val> Ṣe imudojuiwọn aaye iwọn iye ti o kere julọ fun esi.
  --base <path>                  Akopọ ipilẹ ti node GaiaNet.
  --help                         Ṣe afihan iṣẹ yii ranṣẹ iranlọwọ
```

E ṣe!

## Awọn ohun elo & Fifun ni ẹsan

Ṣe o n wa awọn iwe aṣẹ? Ṣayẹwo [awọn iwe aṣẹ](https://docs.gaianet.ai/intro) tabi [Itọsọna Ifowosowopo](https://github.com/Gaianet-AI/gaianet-node/blob/main/.github/CONTRIBUTING.md) jade. A tun gba iwẹ kika [Awesome-Gaia](https://github.com/GaiaNet-AI/awesome-gaia) fun atokọ ti awọn irinṣẹ, awọn iṣẹ-ṣiṣe, ati awọn ohun elo lati ọdọ awọn alagbase Gaia.

Ṣe o fẹ bá awọn alagbase sọrọ? Wọle si [Telegram](https://t.me/+a0bJInD5lsYxNDJl) wa ki o pin awọn ero rẹ ati ohun ti o ti kọ pẹlu Gaianet.

Ṣe o ri aṣiṣe? Lọ si [ibi ifọrọranṣẹ](https://github.com/GaiaNet-AI/gaianet-node/issues) wa ati a o ṣe ohun ti o ṣee ṣe lati ran ọ lọwọ. A nifẹẹ si gbigba awọn ibeere, pẹlu!

A n reti gbogba awọn alagbase Gaianet lati ṣe amulo awọn ofin ti [Ilana Iṣẹ](https://github.com/GaiaNet-AI/gaianet-node/blob/main/.github/CODE_OF_CONDUCT.md) wa.

[**→ Bẹrẹ ifowosowopo lori GitHub**](https://github.com/GaiaNet-AI/gaianet-node/blob/main/.github/CONTRIBUTING.md)

### Awọn alagbase

<a href="https://github.com/GaiaNet-AI/gaianet-node/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=GaiaNet-AI/gaianet-node" alt="Awọn alagbase iṣẹ-ṣiṣe Gaia" />
</a>