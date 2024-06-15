# Docker support

> For Nvidia devices: replace the `latest` tag with `cuda12` or `cuda11`. If you need to build the images yourself, replace `Dockerfile` with `Dockerfile.cuda12` or `Dockerfile.cuda11`.

## Quick start

Start a Docker container for the node. It will print running logs from the GaiaNet node in this terminal. 

```
docker run --name gaianet \
  -p 8080:8080 \
  -v $(pwd)/qdrant_storage:/root/gaianet/qdrant/storage:z \
  secondstate/gaianet-phi-3-mini-instruct-4k_paris:latest
```

The node is ready when it shows `The GaiaNet node is started at: https://...` on the console.
You can go to that URL from your browser to interact with the GaiaNet node.

The docker image contains the LLM and embedding models required by the node. However, the vector
collection snapshot (i.e., knowledge base) is downloaded and imported at the time when the node
starts up. That is because the knowledge based could be updated frequently. The `qdrant_storage`
directory on the host machine stores the vector database content.

## Stop and re-start

You can stop and re-start the node as follows. Every time you re-start, it will re-initailize the vector
collection (knowledge base).

```
docker stop gaianet
docker start gaianet
```

You can also delete the node if you no longer needs it.

```
docker stop gaianet
docker rm gaianet
```

## Build a node image locally

Each GaiaNet is defined by a `config.json` file. It defines the node's required
LLM and embedding models, model parameters,
prompts, and vector snapshots (e.g., knowledge base). 
The following command builds a Docker image with two platforms 
for a node based on the specified `config.json` file.

```
docker buildx build . --platform linux/arm64,linux/amd64 \
  --tag secondstate/gaianet-phi-3-mini-instruct-4k_paris:latest -f Dockerfile \
  --build-arg CONFIG_URL=https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/config.json
```

You can publish your node for other people to use it.

```
docker push secondstate/gaianet-phi-3-mini-instruct-4k_paris:latest
```

## Make changes to the node

As we discussed, the node is defined by `config.json`. You can start a node, and then update its `config.json`
by copying your own `config.json` into the container.

```
docker cp /local/path/to/config.json gaianet:/root/gaianet/config.json
```

THen, restart the node for the new `config.json` to take effect.

```
docker stop gaianet
docker start gaianet
```

## Change the node ID

You can update the node ID (Ethereum address) associated with the node. Start the node and copy the `nodeid.json`
file, as well as the keystore file defined in `nodeid.json` into the container.

```
docker cp /local/path/to/nodeid.json gaianet:/root/gaianet/nodeid.json
docker cp /local/path/to/1234-abcd-key-store gaianet:/root/gaianet/1234-abcd-key-store
```

THen, restart the node for the new address and keystore to take effect.

```
docker stop gaianet
docker start gaianet
```

