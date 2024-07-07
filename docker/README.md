# Docker support

You can run all the commands in this document without any change on any machine with the latest Docker and at least 8GB of RAM available to the container.
By default, the container uses the CPU to perform computations, which could be slow for large LLMs. For GPUs,

* Mac: Everything here works on [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/). However, the Apple GPU cores will not be available inside Docker containers until [WebGPU is supported by Docker](https://github.com/LlamaEdge/LlamaEdge/blob/main/docker/webgpu.md) later in 2024.
* Windows and Linux with Nvidia GPU: You will need to install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installation) for Docker. In the instructions below, replace the `latest` tag with `cuda12` or `cuda11` to use take advantage of the GPU, and add the `--device nvidia.com/gpu=all` flag. If you need to build the images yourself, replace `Dockerfile` with `Dockerfile.cuda12` or `Dockerfile.cuda11`.

## Quick start

Start a Docker container for the GaiaNet node. It will print running logs from the GaiaNet node in this terminal. 

```
docker run --name gaianet \
  -p 8080:8080 \
  -v $(pwd)/qdrant_storage:/root/gaianet/qdrant/storage:z \
  gaianet/phi-3-mini-instruct-4k_paris:latest
```

The node is ready when it shows `The GaiaNet node is started at: https://...` on the console.
You can go to that URL from your browser to interact with the GaiaNet node.

The docker image contains the LLM and embedding models required by the node. However, the vector
collection snapshot (i.e., knowledge base) is downloaded and imported at the time when the node
starts up. That is because the knowledge based could be updated frequently. The `qdrant_storage`
directory on the host machine stores the vector database content.

Alternatively, the command to run the GaiaNet on your Nvidia CUDA 12 machine is as follows.

```
docker run --name gaianet \
  -p 8080:8080 --device nvidia.com/gpu=all \
  -v $(pwd)/qdrant_storage:/root/gaianet/qdrant/storage:z \
  gaianet/phi-3-mini-instruct-4k_paris:cuda12
```

## Stop and re-start

You can stop and re-start the node as follows. Every time you re-start, it will re-initailize the vector
collection (knowledge base).

```
docker stop gaianet
docker start gaianet
```

NOTE: When you restart the node, the log messages will no longer be printed to the console.
You will need to wait for a few minutes before the restarted node comes back online. You can still see
the logs by logging into the container as follows.

```
docker exec -it gaianet /bin/bash
tail -f /root/gaianet/log/start-llamaedge.log
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
  --tag gaianet/phi-3-mini-instruct-4k_paris:latest -f Dockerfile \
  --build-arg CONFIG_URL=https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/config.json
```

You can publish your node for other people to use it.

```
docker push gaianet/phi-3-mini-instruct-4k_paris:latest
```

## Make changes to the node

You can update the configuration parameters of the node, such as context size for the models, by
executing the `config` command on the `gaianet` program inside the container.
For example, the following command changes the chat LLM's context size to 8192 tokens.

```
docker exec -it gaianet /root/gaianet/bin/gaianet config --chat-ctx-size 8192
```

Then, restart the node for the new configuration to take effect.
You will need to wait for a few minutes for the server to start again, or you can monitor
the log files inside the container as discussed above.

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

