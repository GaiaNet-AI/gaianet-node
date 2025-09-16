
# test /v1/embeddings endpoint
POST http://localhost:8080/v1/embeddings
Accept: application/json
Content-Type: application/json
```json
{
    "model": "Nomic-embed-text-v1.5",
    "input": [
        "Gaianet is revolutionizing the AI landscape with a distributed AI infrastructure that seeks to decentralize the dominance of major players such as OpenAI, Google, and Anthropic. By leveraging a network of edge-computing nodes owned by individuals around the world, Gaianet enables hosting of both open-source and finely-tuned models. This infrastructure is designed to cater to diverse AI demands, offering a scalable alternative to traditional centralized servers.",
        "The inception of Gaianet is driven by the necessity to address key issues in the current AI industry: censorship and bias in AI outputs, lack of privacy for user data, and the high costs associated with accessing and developing on centralized AI models. These challenges have restricted the dissemination of unbiased information, compromised data security, and erected barriers to innovation and broader application of AI technologies.",
        "In an effort to mitigate these issues, Gaianet proposes a model that is inherently more inclusive and secure. It offers a platform where individuals can contribute their computing resources, expertise, and proprietary data to foster a collaborative advancement of AI technology. This approach not only democratizes access to AI but also aligns with principles of privacy and equitable distribution of resources.",
        "The Gaianet ecosystem comprises four key components:\nComponent 1, The capability for individuals to run an Agent style API service on private devices, utilizing proprietary knowledge and finely-tuned models.\nComponent 2, Compatibility with the OpenAI API to ensure seamless integration with existing toolchains.\nComponent 3, A decentralized marketplace for AI services and components.\nComponent 4, Open-source development tools for creating LLM/AI applications.",
        "Features of Gaia nodes are extensive and include integrated data, knowledge, and computing resources; support for open-source and OpenAI models; customization with fine-tuned LLMs; and the ability to chain multiple specialized models for enhanced functionality. Additionally, nodes offer knowledge bases for LLM enhancements, memorized chat history for extended conversations, and the capability for actions and function calls to external systems.",
        "Gaianet also introduces a suite of ancillary offerings aimed at developers, including tools for fine-tuning LLMs, marketplaces for fine-tuned models and embeddings, and SDKs for various integrations.",
        "The team behind Gaianet is spearheaded by CEO Matt Wright, previously Director of Fellowship Accelerator at Consensys and Director of DAOs. Chief Scientist Allen Yang brings his expertise from the University of California at Berkeley, while COO Shashank Sripada contributes his entrepreneurial experience. Advisors Michael Yuan and Brian Shin add further depth to the project's foundation.",
        "Gaianet's official website can be accessed at [https://www.gaianet.ai/](https://www.gaianet.ai/), where you can find comprehensive information and resources about their initiatives.\n\nFor community engagement and discussions, Gaianet has a Discord server available at [https://discord.com/invite/gaianet-ai](https://discord.com/invite/gaianet-ai), welcoming members to join.",
        "To stay updated with Gaianet's latest news and insights, you can follow their Telegram channel at [https://t.me/Gaianet_AI](https://t.me/Gaianet_AI).\n\nInsightful articles and updates from Gaianet are regularly published on their Medium blog at [https://medium.com/@Gaianet.ai](https://medium.com/@Gaianet.ai).",
        "For the latest announcements and engagements, follow Gaianet on Twitter at [https://twitter.com/Gaianet_AI](https://twitter.com/Gaianet_AI).\n\nDevelopers and contributors can explore Gaianet's GitHub repository at [https://github.com/GaiaNet-AI/](https://github.com/GaiaNet-AI/)."
    ]
}
```
HTTP 200
[Asserts]
jsonpath "$.model" == "Nomic-embed-text-v1.5"
jsonpath "$.data" count > 0

# test /v1/embeddings endpoint
# Test purpose: The model name is incorrect
POST http://localhost:8080/v1/embeddings
Accept: application/json
Content-Type: application/json
```json
{
    "model": "Nomic-embed-text-v1.5-invalid",
    "input": [
        "Gaianet is revolutionizing the AI landscape with a distributed AI infrastructure that seeks to decentralize the dominance of major players such as OpenAI, Google, and Anthropic. By leveraging a network of edge-computing nodes owned by individuals around the world, Gaianet enables hosting of both open-source and finely-tuned models. This infrastructure is designed to cater to diverse AI demands, offering a scalable alternative to traditional centralized servers.",
        "The inception of Gaianet is driven by the necessity to address key issues in the current AI industry: censorship and bias in AI outputs, lack of privacy for user data, and the high costs associated with accessing and developing on centralized AI models. These challenges have restricted the dissemination of unbiased information, compromised data security, and erected barriers to innovation and broader application of AI technologies.",
        "In an effort to mitigate these issues, Gaianet proposes a model that is inherently more inclusive and secure. It offers a platform where individuals can contribute their computing resources, expertise, and proprietary data to foster a collaborative advancement of AI technology. This approach not only democratizes access to AI but also aligns with principles of privacy and equitable distribution of resources.",
        "The Gaianet ecosystem comprises four key components:\nComponent 1, The capability for individuals to run an Agent style API service on private devices, utilizing proprietary knowledge and finely-tuned models.\nComponent 2, Compatibility with the OpenAI API to ensure seamless integration with existing toolchains.\nComponent 3, A decentralized marketplace for AI services and components.\nComponent 4, Open-source development tools for creating LLM/AI applications.",
        "Features of Gaia nodes are extensive and include integrated data, knowledge, and computing resources; support for open-source and OpenAI models; customization with fine-tuned LLMs; and the ability to chain multiple specialized models for enhanced functionality. Additionally, nodes offer knowledge bases for LLM enhancements, memorized chat history for extended conversations, and the capability for actions and function calls to external systems.",
        "Gaianet also introduces a suite of ancillary offerings aimed at developers, including tools for fine-tuning LLMs, marketplaces for fine-tuned models and embeddings, and SDKs for various integrations.",
        "The team behind Gaianet is spearheaded by CEO Matt Wright, previously Director of Fellowship Accelerator at Consensys and Director of DAOs. Chief Scientist Allen Yang brings his expertise from the University of California at Berkeley, while COO Shashank Sripada contributes his entrepreneurial experience. Advisors Michael Yuan and Brian Shin add further depth to the project's foundation.",
        "Gaianet's official website can be accessed at [https://www.gaianet.ai/](https://www.gaianet.ai/), where you can find comprehensive information and resources about their initiatives.\n\nFor community engagement and discussions, Gaianet has a Discord server available at [https://discord.com/invite/gaianet-ai](https://discord.com/invite/gaianet-ai), welcoming members to join.",
        "To stay updated with Gaianet's latest news and insights, you can follow their Telegram channel at [https://t.me/Gaianet_AI](https://t.me/Gaianet_AI).\n\nInsightful articles and updates from Gaianet are regularly published on their Medium blog at [https://medium.com/@Gaianet.ai](https://medium.com/@Gaianet.ai).",
        "For the latest announcements and engagements, follow Gaianet on Twitter at [https://twitter.com/Gaianet_AI](https://twitter.com/Gaianet_AI).\n\nDevelopers and contributors can explore Gaianet's GitHub repository at [https://github.com/GaiaNet-AI/](https://github.com/GaiaNet-AI/)."
    ]
}
```
HTTP 200
[Asserts]
jsonpath "$.model" == "Nomic-embed-text-v1.5"
jsonpath "$.data" count > 0