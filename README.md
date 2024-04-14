# Run your own GaiaNet node

## Quick start

Install the default node software stack with a single line of command on Mac, Linux, or Windows WSL.

```bash
bash <(curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh')
```

Next, you can start the node as follows.

```bash
bash <(curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/start.sh')
```

The script prints the official node address on the console as follows.

```
... ... https://0xf63939431ee11267f4855a166e11cc44d24960c0.gaianet.xyz
```

You can open a browser to that URL to see the node information and then chat with the AI agent on the node.

To stop the node, you can run the following script.

```bash
bash <(curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/stop.sh')
```

## Customize the node

The primary reason to run the GaiaNet node is to deploy your own AI agent with your own finetuned LLM model and your own private knowledge. 
For example, you can finetune an LLM with your blog posts, and then supplement it with your private notes as a knowledge base. The GaiaNet node that runs this set of finetuned LLM and knowledge base will "speak" like your public persona!

Visit our demo site to select models and knowledge bases from our open source community to create a `config.json` file.

https://gaianet-ai.github.io/Generate-config-demo/

Copy the generated `config.json` file into the `~/gaianet` directory.
Then, run the install script again.

```bash
bash <(curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh')
```

Start the node.

```bash
bash <(curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/start.sh')
```

## Run multiple nodes on a single machine

For a larger machine, you can run multiple GaiaNet nodes. But please note that, for now, only one node can register on a GiaiaNet domain to be publicly accessible. First, you can start the first (and default) node as above.

For the second node, you will first create a `config.json` file for its models, prompts, and knowledge collections. Pay special attention to the following.

* The `llamaedge_port` value must be unqiue and probably not `8080`.
* The `embedding_collection_name` value must be unique and probably not `default`.

Upload the `config.json` file to a service that makes it available via a public URL (e.g., GitHub, Gist, or Dropbox). Next, install the second node in a new directory. Let's use `/home/username/gaianet2` as its base directory. You can run the installer as follows.

```bash
bash <(curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh') --config https://hosting.service/config.json --base /home/username/gaianet2
```

Start the second node in "local only" mode.

```bash
bash <(curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/start.sh') --base /home/username/gaianet2 --local
```

While the second node cannot be registered on the GaiaNet domain, you can access the node locally. Replace the port number `8081` with the `llamaedge_port` in your `/home/username/gaianet2/config.json`.

```
http://localhost:8081
```

To stop the second node, do the following.

```bash
bash <(curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/stop.sh') --base /home/username/gaianet2
```

Have fun!

