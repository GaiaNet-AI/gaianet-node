# Demo Scripts

## config.sh

```bash
./config.sh \
    --chat https://huggingface.co/second-state/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/TinyLlama-1.1B-Chat-v1.0-Q5_K_M.gguf \
    --embedding https://huggingface.co/second-state/All-MiniLM-L6-v2-Embedding-GGUF/resolve/main/all-MiniLM-L6-v2-ggml-model-f16.gguf \
    --snapshot https://huggingface.co/datasets/gaianet/paris/resolve/main/paris_384_all-minilm-l6-v2_f16.snapshot
```

## init.sh

```bash
./init.sh

# run `source $HOME/.bashrc` to update the environment variables after running `init.sh`
```

Task list of `init.sh`:

- Install WasmEdge with wasi-nn_ggml + rustls plugins
- Install Qdrant
- Download gguf chat model (in `config.json`) to `$HOME/gaianet`
- Download gguf embedding model (in `config.json`) to `$HOME/gaianet`
- Download `llama-api-server.wasm` (Not release version) to `$HOME/gaianet`
- Download `dashboard` to `$HOME/gaianet`
- Create `qdrant` directory in `$HOME/gaianet` as the default data directory of Qdrant
- Recover the snapshot (in `config.json`) to Qdrant
- Download `gaianet-domain` to `$HOME/gaianet`

## start.sh

```bash
./start.sh
```

Task list of `start.sh`:

- Start Qdrant instance at `http://0.0.0.0:6333` (REST API)
- Start LlamaEdge API Server at `http://0.0.0.0:8080`
  - The gaianet branded chatbot-ui at `http://0.0.0.0:8080/index.html`
- Start gaianet-domain at `http://<your_subdomain>.gaianet.xyz:8080`

## stop.sh

```bash
./stop.sh
```

Task list of `stop.sh`:

- Stop Qdrant instance
- Stop LlamaEdge API Server
- Stop gaianet-domain

## Test

Note that using default `config.json` to start the services, the following command is used to do a RAG query test.

```bash
curl -s -X POST http://localhost:8080/v1/chat/completions \
    -H 'accept:application/json' \
    -H 'Content-Type: application/json' \
    -d '{"messages":[{"role":"user","content":"What is the location of Paris, France on the Seine River?\n"}],"model":"Llama-2-7b-chat-hf-Q5_K_M","stream":false}'
```
