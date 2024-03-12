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
