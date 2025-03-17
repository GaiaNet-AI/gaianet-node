# Changes on GaiaNode 0.5.0

## Log Files

In the `log` directory, there are the following log files:

- `start-gaia-nexus.log` keeps the log messages related to starting the `gaia-nexus` server. If empty, means the server is running correctly.
- `gaia-nexus.log` keeps the log messages related to the running `gaia-nexus` server.
- `chat-server.log` keeps the log messages related to the running chat server.
- `embedding-server.log` keeps the log messages related to the running embedding server.

## Server Info

The `/v1/info` endpoint returns the server info of a Gaia node. The following JSON object demonstrates the server info of a Gaia node:

```json
{
  "node_version": "0.4.21",
  "servers": {
    "chat-server-cb38ab65-877d-4a55-baff-5ccc5e82af70": {
      "type": "llama",
      "version": "0.16.9",
      "port": "9068",
      "chat_model": {
        "name": "Llama-3.2-3B-Instruct",
        "type": "chat",
        "ctx_size": 16384,
        "batch_size": 128,
        "ubatch_size": 128,
        "prompt_template": "Llama3Chat",
        "n_predict": -1,
        "n_gpu_layers": 100,
        "temperature": 1.0,
        "top_p": 1.0,
        "repeat_penalty": 1.1,
        "presence_penalty": 0.0,
        "frequency_penalty": 0.0,
        "split_mode": "layer"
      },
      "extras": {}
    },
    "embeddings-server-dd14e37d-defb-4088-95bf-34ae2ca389c3": {
      "type": "llama",
      "version": "0.16.9",
      "port": "9069",
      "embedding_model": {
        "name": "Nomic-embed-text-v1.5",
        "type": "embedding",
        "ctx_size": 8192,
        "batch_size": 8192,
        "ubatch_size": 8192,
        "prompt_template": "Embedding",
        "n_predict": -1,
        "n_gpu_layers": 100,
        "use_mmap": true,
        "temperature": 0.8,
        "top_p": 0.9,
        "repeat_penalty": 1.0,
        "presence_penalty": 0.0,
        "frequency_penalty": 0.0,
        "split_mode": "layer"
      },
      "extras": {}
    }
  }
}
```

- `node_version`: the version of the Gaia node.
- `servers`: a map of server info.
  - `chat-server-cb38ab65-877d-4a55-baff-5ccc5e82af70`: the `ServerId` of the running chat server.
  - `embeddings-server-dd14e37d-defb-4088-95bf-34ae2ca389c3`: the `ServerId` of the running embedding server.

Note that from `0.5.0`, the server info is ONLY pushed after a new downstream node is registered to the `gaia-nexus` server. The `push` operation will try 3 times if it fails.

## Health Status

The following JSON object demonstrates the health status of a Gaia node:

```json
{
  "rag": true,
  "servers": {
    "chat": [
      "chat-server-cb38ab65-877d-4a55-baff-5ccc5e82af70"
    ],
    "embeddings": [
      "embeddings-server-dd14e37d-defb-4088-95bf-34ae2ca389c3"
    ]
  }
}
```

- `rag`: `true` if the node is running in the `RAG` mode; otherwise, `false`.
- `servers` lists the running servers on the node.
  - `chat` contains the `ServerId`s of the running chat servers.
  - `embeddings` contains the `ServerId`s of the running embedding servers.

Note that the `chat` and `embeddings` must be present and not empty if `rag` is `true`. Otherwise, this node is not a valid `RAG` node.
