# 나만의 GaiaNet 노드 실행하기

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

[일본어(日本語)](README-ja.md) | [중국어(中文)](README-cn.md)  | [터키어 (Türkçe)](README-tr.md) | [페르시아어(فارسی)](README-fa.md) | [아랍어 (العربية)](README-ar.md) | [인도네시아어](README-id.md) | [러시아어 (русский)](README-ru.md) | [포르투갈어 (português)](README-pt.md) | 여러분의 언어로 README를 번역하는 데 도움을 주세요.

우리의 작업이 마음에 드시나요? ⭐ Star로 응원해 주세요!

[공식 문서](https://docs.gaianet.ai/) 및 [Manning ebook](https://www.manning.com/liveprojectseries/open-source-llms-on-your-own-computer)에서 오픈소스 모델을 커스터마이징하는 방법을 확인하세요.

---

## 빠른 시작

Mac, Linux 또는 Windows WSL에서 다음 단일 명령줄로 기본 노드 소프트웨어 스택을 설치하세요.

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

> 설치 후, 화면에 표시되는 안내에 따라 환경 경로를 설정하세요. 명령어는 `source`로 시작됩니다.

![이미지](https://github.com/user-attachments/assets/dc75817c-9a54-4994-ab90-1efb1a018b17)

노드를 초기화합니다. 이 과정에서는 `$HOME/gaianet/config.json` 파일에 명시된 모델 파일과 벡터 데이터베이스 파일을 다운로드하며, 파일 크기가 크기 때문에 몇 분이 소요될 수 있습니다.

```bash
gaianet init
```

다음 명령어로 노드를 시작합니다.

```bash
gaianet start
```

스크립트는 다음과 같이 콘솔에 공식 노드 주소를 출력합니다. 해당 URL을 브라우저에서 열어 노드 정보를 확인하고 노드의 AI 에이전트와 채팅할 수 있습니다.

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

노드를 중지하려면 다음 명령어를 실행하세요.

```bash
gaianet stop
```

## 설치 가이드

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary> 출력 예시 보기 </summary>

```console
[+] 기본 설정 파일 다운로드 중...
[+] nodeid.json 다운로드 중...
[+] WasmEdge 설치 중 (wasi-nn_ggml 플러그인 포함)...
Info: Linux-x86_64 감지됨
Info: WasmEdge 설치 경로: /home/azureuser/.wasmedge
Info: WasmEdge-0.13.5 가져오는 중

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
...
설치 완료!
```
</details>

기본적으로 `$HOME/gaianet`에 설치됩니다. 다른 디렉토리에 설치하려면:

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## 노드 초기화

```bash
gaianet init
```

<details><summary> 출력 결과는 다음과 같을 것입니다 : </summary>

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

`init` 명령은 `$HOME/gaianet/config.json` 파일의 설정에 따라 노드를 초기화합니다. 미리 설정된 프리셋 구성 중 일부를 사용할 수 있습니다. 예를 들어, 다음 명령은 런던 가이드북을 지식 기반으로 하는 llama-3 8B 모델로 노드를 초기화합니다.

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json
```

미리 설정된 프리셋 구성 목록을 보려면 `gaianet init --help`를 실행하세요.

`gaianet_docs`와 같이 미리 설정된 구성 외에도, 원하는 상태로 노드를 초기화하고 싶다면 자체적으로 만든 `config.json`의 URL을 입력합니다.


대체 디렉토리에 설치된 노드를 `init`해야 하는 경우 다음과 같이 하세요.

설정 목록 확인:

```bash
gaianet init --help
```

대체 경로 초기화:

```bash
gaianet init --base $HOME/gaianet.alt
```

## 노드 시작

```bash
gaianet start
```

<details><summary> 출력 결과는 다음과 같을 것입니다 : </summary>
```bash
[+] Starting Qdrant instance ...
    Qdrant 인스턴스 시작됨 (pid: 39762)
[+] Starting LlamaEdge API Server ...
    Run the following command to start the LlamaEdge API Server:
wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"
[+] LlamaEdge API 서버 시작됨 (pid: 39796)
```
</details>

로컬 환경에서 사용하기 위해 노드를 시작하는 명령입니다. 이 경우 `localhost`를 통해서만 접근 가능하며 GaiaNet 도메인의 공개 URL에서는 사용할 수 없습니다.

```bash
gaianet start --local-only
```

다른 기본 경로에 설치된 노드를 시작할 수도 있습니다.

```bash
gaianet start --base $HOME/gaianet.alt
```

### 노드 중지하기

```bash
gaianet stop
```

<details><summary> 출력 예시 보기 </summary>

```bash
[+] WasmEdge, Qdrant, frpc 중지 중...
```

</details>

대체 경로 노드 중지:

```bash
gaianet stop --base $HOME/gaianet.alt
```

### 설정 업데이트 하기

`gaianet config` 하위 명령을 사용하여 `config.json` 파일에 정의된 주요 필드들을 업데이트할 수 있습니다. 구성을 업데이트한 후에는 반드시 `gaianet init`을 다시 실행해야 합니다.

예를 들어 `chat` 필드를 업데이트하려면 다음 명령어를 사용할 수 있습니다 :

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```
예를 들어 `chat_ctx_size` 필드를 업데이트하려면 다음 명령을 사용하세요 :

```bash
gaianet config --chat-url "https://your-model-url"
gaianet config --chat-ctx-size 5120
```

다음은 `config` 하위 명령의 모든 옵션입니다.

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

즐거운 사용 되세요!

## 리소스 & 커뮤니티

- [공식 문서](https://docs.gaianet.ai/intro)
- [기여 가이드](https://github.com/Gaianet-AI/gaianet-node/blob/main/CONTRIBUTING.md)
- [Awesome-Gaia 도구 모음](https://github.com/GaiaNet-AI/awesome-gaia)
- [Telegram 커뮤니티](https://t.me/+a0bJInD5lsYxNDJl)
- [이슈 제보](https://github.com/GaiaNet-AI/gaianet-node/issues)
- [행동 강령](https://github.com/GaiaNet-AI/gaianet-node/blob/main/CODE_OF_CONDUCT.md)

[**→ GitHub에서 기여 시작하기**](https://github.com/GaiaNet-AI/gaianet-node/blob/main/CONTRIBUTING.md)

### 기여자

<a href="https://github.com/GaiaNet-AI/gaianet-node/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=GaiaNet-AI/gaianet-node" alt="Gaia 프로젝트 기여자" />
</a>
