# gaianet-node

## Installation

To install the node, you can use the following command:

  ```bash
  curl -sSf https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install-gaia.sh | bash -s -- --model-url <model-url>
  ```

If you want to install the node and recover a collection from a given collection snapshot by URL or local path, you can use the following command:

  ```bash
  curl -sSf https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install-gaia.sh | bash -s -- --model-url <model-url> --collection-name <recovered-collection-name> --snapshot <snapshot-url-or-path>
  ```

Example: Install the node and recover a collection from a given collection snapshot by local path:

  ```bash
  curl -sSf https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install-gaia.sh | bash -s -- --model-url https://huggingface.co/second-state/Qwen1.5-0.5B-Chat-GGUF/resolve/main/Qwen1.5-0.5B-Chat-Q5_K_M.gguf --collection-name paris-france --snapshot file:////Users/sam/workspace/demo/gaia/paris-5345043712122094-2024-03-12-14-02-37.snapshot

Note that replace the snapshot file path with your own path before running the example command above.
