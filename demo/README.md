# Demo Scripts

## config.sh

```bash
./config.sh \
    --chat https://huggingface.co/second-state/Llama-2-7B-Chat-GGUF/resolve/main/Llama-2-7b-chat-hf-Q5_K_M.gguf \
    --embedding https://huggingface.co/second-state/All-MiniLM-L6-v2-Embedding-GGUF/resolve/main/all-MiniLM-L6-v2-ggml-model-f16.gguf \
    --snapshot https://huggingface.co/datasets/gaianet/paris/resolve/main/paris_4096_llama2-7b.snapshot
```

## init.sh

```bash
./init.sh

# run `source $HOME/.bashrc` to update the environment variables after running `init.sh`
```

Task list of `init.sh`:

- Install WasmEdge with wasi-nn_ggml + rustls plugins
- Install Qdrant
- Download gguf chat model (in `config.json`) to `$HOME/gaia`
- Download gguf embedding model (in `config.json`) to `$HOME/gaia`
- Download `llama-api-server.wasm` (Not release version) to `$HOME/gaia`
- Download `dashboard` to `$HOME/gaia`
- Create `qdrant` directory in `$HOME/gaia` as the default data directory of Qdrant
- Recover the snapshot (in `config.json`) to Qdrant

## start.sh

```bash
./start.sh
```

Task list of `start.sh`:

- Start Qdrant instance at `http://0.0.0.0:6333` (REST API)
- Start LlamaEdge API Server at `http://0.0.0.0:8080`
  - The gaianet branded chatbot-ui at `http://0.0.0.0:8080/index.html`

## ,stop.sh

```bash
./stop.sh
```
