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

Have fun!

