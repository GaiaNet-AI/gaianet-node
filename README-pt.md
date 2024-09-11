# Início Rápido

Instale a pilha de software padrão do nó com uma única linha de comando no Mac, Linux ou Windows WSL.

```bash
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
```

Em seguida, siga as instruções na tela para configurar o caminho do ambiente. A linha de comando começará com `source`.

Inicialize o nó. Ele fará o download dos arquivos de modelo e do banco de dados vetorial especificados no arquivo `$HOME/gaianet/config.json`, e isso pode levar alguns minutos, pois os arquivos são grandes.

```bash
gaianet init
```

Inicie o nó.

```bash
gaianet start
```

O script imprimirá o endereço oficial do nó no console como segue.
Você pode abrir um navegador nesse URL para ver as informações do nó e depois conversar com o agente de IA no nó.

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.us.gaianet.network
```

Para parar o nó, você pode executar o seguinte script.

```bash
gaianet stop
```

## Guia de Instalação

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
```

<details><summary>A saída deve ser semelhante a esta:</summary>

```console
[+] Baixando arquivo de configuração padrão...

[+] Baixando nodeid.json...

[+] Instalando WasmEdge com o plugin wasi-nn_ggml...

Info: Linux-x86_64 detectado

Info: Instalação do WasmEdge em /home/azureuser/.wasmedge

Info: Buscando WasmEdge-0.13.5

/tmp/wasmedge.2884467 ~/gaianet
######################################################################## 100.0%
~/gaianet
Info: Buscando WasmEdge-GGML-Plugin

Info: Versão CUDA detectada:

/tmp/wasmedge.2884467 ~/gaianet
######################################################################## 100.0%
~/gaianet
Instalação do wasmedge-0.13.5 bem-sucedida
Binários do WasmEdge acessíveis

    O Runtime WasmEdge versão 0.13.5 está instalado em /home/azureuser/.wasmedge/bin/wasmedge.


[+] Instalando binário do Qdrant...
    * Baixando binário do Qdrant
################################################################################################## 100.0%

    * Inicializando diretório do Qdrant

[+] Baixando o rag-api-server.wasm...
################################################################################################## 100.0%

[+] Baixando dashboard...
################################################################################################## 100.0%
```

</details>

Por padrão, ele instala no diretório `$HOME/gaianet`. Você também pode optar por instalar em um diretório alternativo.

```bash
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/gaianet.alt
```

## Inicialize o nó

```
gaianet init
```

<details><summary>A saída deve ser semelhante a esta:</summary>

```bash
[+] Baixando Llama-2-7b-chat-hf-Q5_K_M.gguf...
############################################################################################################################## 100.0%############################################################################################################################## 100.0%

[+] Baixando all-MiniLM-L6-v2-ggml-model-f16.gguf...

############################################################################################################################## 100.0%############################################################################################################################## 100.0%

[+] Criando 'coleção padrão' na instância do Qdrant...

    * Iniciando uma instância do Qdrant...

    * Removendo a coleção 'padrão' existente do Qdrant...

    * Baixando snapshot da coleção do Qdrant...
############################################################################################################################## 100.0%############################################################################################################################## 100.0%

    * Importando o snapshot da coleção do Qdrant...

    * Recuperação concluída com sucesso
```

</details>

O comando `init` inicializa o nó de acordo com o arquivo `$HOME/gaianet/config.json`. Você pode usar algumas de nossas configurações predefinidas. Por exemplo, o comando abaixo inicializa um nó com o modelo llama-3 8B com um guia de Londres como base de conhecimento.

```bash
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/llama-3-8b-instruct_london/config.json
```

Para ver uma lista de configurações predefinidas, você pode usar `gaianet init --help`.
Além de configurações predefinidas como `gaianet_docs`, você também pode passar uma URL para o seu próprio `config.json` para que o nó seja inicializado no estado desejado.

Se você precisar inicializar um nó instalado em um diretório alternativo, faça o seguinte:

```bash
gaianet init --base $HOME/gaianet.alt
```

## Inicie o nó

```
gaianet start
```

<details><summary>A saída deve ser semelhante a esta:</summary>

```bash
[+] Iniciando instância do Qdrant...

    Instância do Qdrant iniciada com pid: 39762

[+] Iniciando o LlamaEdge API Server...

    Execute o seguinte comando para iniciar o LlamaEdge API Server:

wasmedge --dir .:./dashboard --nn-preload default:GGML:AUTO:Llama-2-7b-chat-hf-Q5_K_M.gguf --nn-preload embedding:GGML:AUTO:all-MiniLM-L6-v2-ggml-model-f16.gguf rag-api-server.wasm --model-name Llama-2-7b-chat-hf-Q5_K_M,all-MiniLM-L6-v2-ggml-model-f16 --ctx-size 4096,384 --prompt-template llama-2-chat --qdrant-collection-name default --web-ui ./ --socket-addr 0.0.0.0:8080 --log-prompts --log-stat --rag-prompt "Use os seguintes trechos de contexto para responder à pergunta do usuário.\nSe você não souber a resposta, apenas diga que não sabe, não tente inventar uma resposta.\n----------------\n"


    LlamaEdge API Server iniciado com pid: 39796
```

</details>

Você pode iniciar o nó para uso local. Ele será acessível apenas via `localhost` e não estará disponível em nenhum dos URLs públicos do domínio GaiaNet.

```bash
gaianet start --local-only
```

Você também pode iniciar um nó instalado em um diretório base alternativo.

```bash
gaianet start --base $HOME/gaianet.alt
```

### Pare o nó

```bash
gaianet stop
```

<details><summary>A saída deve ser semelhante a esta:</summary>

```bash
[+] Parando WasmEdge, Qdrant e frpc...
```

</details>

Pare um nó instalado em um diretório base alternativo.

```bash
gaianet stop --base $HOME/gaianet.alt
```

### Atualizar Configuração

Usando o subcomando `gaianet config` você pode atualizar os campos-chave definidos no arquivo `config.json`. Você DEVE executar `gaianet init` novamente após atualizar a configuração.

Para atualizar o campo `chat`, por exemplo, use o seguinte comando:

```bash
gaianet config --chat-url "https://huggingface.co/second-state/Llama-2-13B-Chat-GGUF/resolve/main/Llama-2-13b-chat-hf-Q5_K_M.gguf"
```

Para atualizar o campo `chat_ctx_size`, por exemplo, use o seguinte comando:

```bash
gaianet config --chat-ctx-size 5120
```

Abaixo estão todas as opções do subcomando `config`.

```console
$ gaianet config --help

Usage: gaianet config [OPTIONS]

Options:
  --chat-url <url>               Atualiza a URL do modelo de chat.
  --chat-ctx-size <val>          Atualiza o tamanho do contexto do modelo de chat.
  --embedding-url <url>          Atualiza a URL do modelo de embedding.
  --embedding-ctx-size <val>     Atualiza o tamanho do contexto do modelo de embedding.
  --prompt-template <val>        Atualiza o template do prompt do modelo de chat.
  --port <val>                   Atualiza a porta do LlamaEdge API Server.
  --system-prompt <val>          Atualiza o prompt do sistema.
  --rag-prompt <val>             Atualiza o prompt RAG.
  --rag-policy <val>             Atualiza a política RAG [Valores possíveis: system-message, last-user-message].
  --reverse-prompt <val>         Atualiza o prompt reverso.
  --domain <val>                 Atualiza o domínio do nó GaiaNet.
  --snapshot <url>               Atualiza o snapshot do Qdrant.
  --qdrant-limit <val>           Atualiza o número máximo de resultados a serem retornados.
  --qdrant-score-threshold <val> Atualiza o limite mínimo de pontuação para o resultado.
  --base <path>                  O diretório base do nó GaiaNet.
  --help                         Mostra esta mensagem de ajuda
```

Divirta-se!
