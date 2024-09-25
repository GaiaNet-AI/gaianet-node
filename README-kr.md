# GaiaNet 노드 직접 실행하기

우리의 작업이 마음에 드시나요? ⭐ 별표를 눌러주세요!

공식 문서와 오픈 소스 모델을 커스터마이징하는 방법에 대해 [공식문서](https://docs.gaianet.ai/) 와 [매닝 이북](https://www.manning.com/liveprojectseries/open-source-llms-on-your-own-computer) 을 확인해보세요.

## 빠른 시작

Mac, Linux 또는 Windows WSL에서 다음 단일 명령줄로 기본 노드 소프트웨어 스택을 설치하세요.

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

그런 다음 화면에 나타나는 안내에 따라 환경 경로를 설정하세요. 커맨드 라인은 `source`로 시작될 것입니다.

노드를 초기화합니다. `$HOME/gaianet/config.json` 파일에 지정된 모델 파일과 벡터 데이터베이스 파일을 다운로드합니다. 파일들의 용량이 크기 때문에 몇 분 정도 걸릴 수 있습니다.
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

노드를 멈추려면 다음 스크립트를 실행하세요.

```bash
gaianet stop
```

## 설치 가이드

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary> 출력 결과는 다음과 같을 것입니다 : </summary>

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

기본설정으로 `$HOME/gaianet` 경로의 디렉토리에 설치됩니다. 다른 디렉토리에 설치하도록 선택할 수도 있습니다.

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## 노드 초기화 하기

```
gaianet init
```

<details><summary> 출력 결과는 다음과 같을 것입니다 : </summary>
```bash
[+] Downloading Llama-2-7b-chat-hf-Q5_K_M.gguf ...
############################################################################################################################## 100.0%############################################################################################################################## 100.0%
[+] Downloading all-MiniLM-L6-v2-ggml-model-f16.gguf ...
############################################################################################################################## 100.0%######################################기
```
gaianet start
```
<details><summary> 출력 결과는 다음과 같을 것입니다 : </summary>
```bash
[+] Starting Qdrant instance ...
    Qdrant instance started with pid: 39762
[+] Starting LlamaEdge API Server ...
    Run the following command to start the LlamaEdge API Server:
wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use the following pieces of context to answer the user's question.\nIf you don't know the answer, just say that you don't know, don't try to make up an answer.\n----------------\n"
    LlamaEdge API Server started with pid: 39796
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

<details><summary> 출력 결과는 다음과 같을 것입니다 :  </summary>
```bash
[+] Stopping WasmEdge, Qdrant and frpc ...
```
</details>

다른 대체경로에 설치된 노드를 중지하려면 다음 명령어를 사용합니다.

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
