# Qdrant `paris` Collection

## `config.json`

In `config.json`, two fields are used for building or recovering the Qdrant collection:

- `snapshot` field specifies the url of the `paris` collection snapshot file. It is used to recover the collection.

- `document` field specifies the url of the plain text file. It is used to build the `paris` collection.

**Note that the `snapshot` field is prioritized over the `document` field.** When both fields are specified, the `snapshot` field is used to recover the collection. To build the collection, remove the `snapshot` field from `config.json`.

## Example: `config.json` with `document` field

```json
{
    "description": "The default GaiaNet node config with a TinyLLama 1.1B model with a Paris tour guide RAG",
    "public_url": "",
    "chat": "https://huggingface.co/second-state/Llama-2-7B-Chat-GGUF/resolve/main/Llama-2-7b-chat-hf-Q5_K_M.gguf",
    "embedding": "https://huggingface.co/second-state/All-MiniLM-L6-v2-Embedding-GGUF/resolve/main/all-MiniLM-L6-v2-ggml-model-f16.gguf",
    "document": "https://github.com/LlamaEdge/Example-LlamaEdge-RAG/raw/main/paris.txt"
}
```
