# Docker support

## Build your own Docker image locally

```
docker build --tag gaianet .
```

## Start a node

First, start a Docker container for the node. It will print running logs from the GaiaNet node in this terminal. For now, since the GaiaNet node is not yet started, you will see no message on the terminal. That is normal.

```
docker run --rm -p 8080:8080 --name gaianet gaianet
```

Next, open another terminal and run the `gaianet` commands in the container.

```
docker exec -it gaianet /root/gaianet/bin/gaianet init
docker exec -it gaianet /root/gaianet/bin/gaianet start
```

If you do not have sufficient memory allocated for your Docker image, you might try a smaller model.

```
docker exec -it gaianet /root/gaianet/bin/gaianet stop
docker exec -it gaianet /root/gaianet/bin/gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/qwen-1.5-1.8b-chat/config.json
docker exec -it gaianet /root/gaianet/bin/gaianet start
```

Once it starts, go to the web URL provided by the GaiaNet node and you can interact with it through the chatbot UI. You should also be able to see running logs from the first terminal where you started the container.

## Stop the node

```
docker container stop gaianet
```


