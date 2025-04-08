# Contributing Guide

First of all, thank you for taking the time to contribute! 🎉

The following is a set of guidelines for contributing to Gaianet. These are just guidelines, not rules, so use your best judgment and feel free to propose changes to this document in a pull request.

Before contributing, we encourage you to read our [Code of Conduct](https://github.com/GaiaNet-AI/gaianet-node/blob/main/.github/CODE_OF_CONDUCT.md).

## Table of Contents

- [Reporting Bugs](#reporting-bugs)
  - [How Do I Submit A Good Bug Report?](#how-do-i-submit-a-good-bug-report)
- [Suggesting Enhancements/Features](#suggesting-enhancementsfeatures)
  - [How Do I Submit A Good Feature Request?](#how-do-i-submit-a-good-feature-request)
- [Understanding the Project](#understanding-the-project)
  - [Prerequisite](#prerequisite)
  - [Project Structure](#project-structure)
  - [Architectural Overview](#architectural-overview)
- [Contributing to the Project](#contributing-to-the-project)
  - [Cloning the Repository (repo)](#cloning-the-repository-repo)
  - [Making your Changes](#making-your-changes)
  - [Testing your Changes](#testing-your-changes)
  - [Code Style Guidelines](#code-style-guidelines)
  - [Opening a Pull Request (PR)](#opening-a-pull-request-pr)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Reporting Bugs

This section guides you through submitting a bug report. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

Before creating a new issue, **[Perform a cursory search](https://github.com/GaiaNet-AI/gaianet-node/issues)** to see if the report exists. If it does, go through the discussion thread and leave a comment instead of opening a new one.

If you find a **Closed** issue that is the same as what you are experiencing, open a new issue and include a link to the original case in the body of your new one.

If you cannot find an open or closed issue addressing the problem, [open a new issue](https://github.com/GaiaNet-AI/gaianet-node/issues).

Be sure to include a **clear title and description**, as much **relevant information** as possible, and a **code sample** or an **executable test case** demonstrating the expected behavior that is not occurring.

### How Do I Submit A Good Bug Report?

A good Bug Report should include the following:

- A clear and descriptive title for the bug report
- The exact steps to reproduce the bug
- The behavior you observed after following the steps
- The behavior you expected to see instead
- What might be causing the issue (if you have any idea)
- Screenshots or animated GIFs of the issue (if applicable)
- If you use the keyboard while following the steps, use [this tool](https://www.cockos.com/licecap/) to record GIFs on macOS and Windows, and [this tool](https://github.com/colinkeenan/silentcast) or [this tool](https://gitlab.gnome.org/Archive/byzanz) on Linux.
- Include system information (OS, hardware specs, etc.)
- The version of GaiaNet you're using (run `gaianet --version`)
- Any error messages or logs related to the issue

[🔝 Back to top](#table-of-contents)

## Suggesting Enhancements/Features

We track Enhancements and Feature Requests as GitHub issues.

Before submitting an enhancement/feature request, **[perform a cursory search](https://github.com/GaiaNet-AI/gaianet-node/issues)** to see if the request exists. If it does, go through the conversation thread to see if there is additional information and contribute to the conversation instead of opening a new one.

If you find a **Closed** issue, go through the conversation thread to see if the feature has already been implemented or rejected. If not, you can open a new issue.

### How Do I Submit A Good Feature Request?

A good Feature Request should include the following:

- A clear and descriptive title of the request
- A detailed description of the request, including:
  - The problem you are trying to solve
  - How you are currently working around the lack of this feature
  - Any possible drawbacks of the feature
  - How the feature can be implemented
- An explanation of why this enhancement would be helpful to the project and the community
- Any links to resources or other projects that might help in implementing the feature
- If possible, include mockups or diagrams of the proposed feature

[🔝 Back to top](#table-of-contents)

## Understanding the Project

Before contributing to the project, you need to understand the project structure and how it works. This section guides you through the project structure and how to run the project locally.

### Prerequisite

This project has Bash-script as the primary programming language and that can be run in your terminal/shell. It also contains code for the registry for Nodes and that is written in Rust. Follow [this link](https://www.rust-lang.org/tools/install) to setup Rust on your machine.

> ⚠️ **Warning:** [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) is recommended for Windows users.

#### Manual setup

1. **Clone the Repository**

```bash
git clone https://github.com/GaiaNet-AI/gaianet-node.git
cd gaianet-node
```

2. **Install Dependencies**

```bash
chmod +x install.sh
./install.sh
```

The project uses several external dependencies. All dependencies are installed with the commands above. The major dependencies are:

- [WasmEdge](https://wasmedge.org/) - WebAssembly runtime for edge and decentralized applications.
- [Qdrant](https://qdrant.tech/) - Performant Vector database.
- [LlamaEdge API server](https://github.com/LlamaEdge/LlamaEdge) - API server for language models.

Follow the [README](https://github.com/GaiaNet-AI/gaianet-node/blob/main/README.md#initialize-the-node) to learn how to initialize and run a node locally.

Every node uses the configuration specified in the [config.json](https://github.com/GaiaNet-AI/gaianet-node/blob/main/config.json) by default.

### Project Structure

This project has two folders and three important scripts:

1. `utils` - Contains the registry that manages and keep track of nodes within the network, including their status, addresses, and keys.
2. `docker` - Has all the setup required to run and use Gaianet on any machine with Docker.
3. `gaianet.sh` - Provides a CLI interface to manage the GaiaNet node with commands like init, start, stop, and config after installation.
4. `install.sh` - Downloads and installs all GaiaNet components including WasmEdge, Qdrant, LlamaEdge API server, and generates a node ID.
5. `uninstall.sh` - Removes all GaiaNet components, services, and directories from your system.

### Architectural Overview

GaiaNet consists of several interconnected components that work together:

1. **Node Registry** - Manages node identity and participation in the network
2. **LLM Integration** - Handles language model loading and inference via LlamaEdge
3. **Vector Database** - Stores embeddings and knowledge in Qdrant
4. **Public Endpoint** - Exposes the node's API and dashboard to the internet
5. **CLI Management** - Provides commands to control the node lifecycle

The typical flow of a GaiaNet node operation:

1. **Installation**: Downloads all required components
2. **Initialization**: Sets up models and knowledge base
3. **Operation**: Serves AI capabilities through the API server
4. **Management**: Allows configuration changes and updates

The communication between components happens primarily through local HTTP APIs and the Qdrant database interface.

## Contributing to the Project

If you want to do more than report an issue or suggest an enhancement, you can contribute to the project by:

- cloning the repository (repo)
- making your changes
- testing your changes
- opening a pull request

### Cloning the Repository

#### 1. Fork the repo

Click the fork button at the top right of the page to create a copy of this repo in your account, or go to the [Gaianet node fork page](https://github.com/GaiaNet-AI/gaianet-node/fork).

After successfully forking the repo, you will be directed to your repo copy.

#### 2. Clone the forked repo

On your forked repo, click the green button that says `Code`. It will open a dropdown menu. Copy the link in the input with the label `HTTPS` or `GitHub CLI` depending on your preferred cloning mode.

For HTTPS, open up your terminal and run the following command:

```bash
git clone <your-clone-link>
# or
git clone https://github.com/<your-username>/gaianet-node.git
```

Replace `<your-username>` with your GitHub username.

You can also clone the repo using the GitHub CLI. To do this, run the following command:

```bash
gh repo clone <your-username>/gaianet-node
```

#### 3. Set up the project

To set up the project, navigate into the project directory and open up the project in your preferred code editor.

```bash
cd gaianet-node
code . # Opens up the project in VSCode
```

### Making your Changes

#### 1. Create a new branch

Create a new branch from the `main` branch. Your branch name should be descriptive of the changes you are making. E.g., `docs-updating-the-readme-file`. Some ideas to get you started:

- For Feature Updates: `feat-<brief 2-4 words-Description>-<ISSUE_NO>`
- For Bug Fixes: `fix-<brief 2-4 words-Description>-<ISSUE_NO>`
- For Documentation: `docs-<brief 2-4 words-Description>-<ISSUE_NO>`

To create a new branch, use the following command:

```bash
git checkout -b <your-branch-name>
```

#### 2. Run the project

If you want to run the project locally, you can use the Gaiant CLI

```bash
# Initialize with a specific configuration
gaianet init --config paris_guide

# Start the node
gaianet start

# Later, stop the node
gaianet stop
```

#### 3. Make your changes

You are to make only one contribution per pull request. It makes it easier to review and merge. If you have multiple bug fixes or features, create separate pull requests for each.

### Testing your Changes

Before submitting your pull request, it's important to properly test your changes:

#### Manual Testing

1. **Basic Functionality Test**: Ensure your changes don't break existing functionality

   ```bash
   # Initialize and start the node
   gaianet init
   gaianet start

   # Test that the API server is responding properly
   curl http://localhost:8080/v1/models

   # Test that the dashboard is accessible
   # Open http://localhost:8080 in your browser

   # Stop the node
   gaianet stop
   ```

2. **Configuration Testing**: If you modified the configuration handling, test with different configurations

   ```bash
   # Test with default config
   gaianet init

   # Test with Paris guide config
   gaianet init --config paris_guide
   ```

3. **Error Handling**: Deliberately introduce errors to verify proper error messages
   ```bash
   # Example: Test with missing configuration
   mv config.json config.json.bak
   gaianet init  # Should show a clear error message
   mv config.json.bak config.json
   ```

#### For Script Modifications

If you modified shell scripts, consider using tools like [ShellCheck](https://www.shellcheck.net/) to verify syntax:

```bash
shellcheck install.sh
shellcheck gaianet.sh
```

#### For Rust Code (Registry)

If you modified the Rust code in the registry:

```bash
# Navigate to the registry directory
cd utils/registry

# Run the Rust tests
cargo test

# Compile to ensure it builds correctly
cargo build --release
```

### Code Style Guidelines

#### For Shell Scripts

- Use 4 spaces for indentation (not tabs)
- Add comments for non-obvious code sections
- Use meaningful variable names
- Follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) for best practices

#### For Rust Code

- Follow the [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- Use the standard Rust formatting (`cargo fmt`)
- Run `cargo clippy` to check for common mistakes and improvements
- Write descriptive comments and documentation

#### For Documentation

- Use Markdown for all documentation files
- Keep line length reasonable (under 100 characters)
- Use proper headings and hierarchical structure
- Include code examples when relevant

#### 4. Commit your changes

Your commit message should give a concise idea of the issue you are solving. It should follow the [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) specification, as this helps us generate the project changelog automatically. A traditional structure of commit looks like so:

```bash
<type>(optional scope): <description>
```

To commit your changes, run the following command:

```bash
git add .
git commit -m "<your_commit_message>"
```

Eg:

```bash
git commit -m "feat: add support for Next.js"
```

#### 5. Push changes

After committing your changes push your local commits to your remote repository.

```bash
git push origin your-branch-name
```

### Opening a Pull Request (PR)

#### 1. Create a new [Pull Request (PR)](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)

Go to the [Gaianet node](https://github.com/GaiaNet-AI/gaianet-node/tree/main) and click the `compare & pull request` button or go to the [Pull Request page](https://github.com/GaiaNet-AI/gaianet-node/pulls) and click on the `New pull request` button. It will take you to the `Open a pull request` page.

> Note: Make sure your PR points to the `main` branch, not any other one.

#### 2. Fill out the PR template

Provide a concise description of what your PR does and why. Include:

- What changes you made
- Why you made these changes
- How these changes can be tested
- Any screenshots or examples if relevant
- A reference to any related issues using the `#issue-number` syntax

#### 3. Wait for review

🎉 Congratulations! You've made your pull request! A maintainer will review and merge your code or request changes. If changes are requested, make them and push them to your branch. Your pull request will automatically track the changes on your branch and update.

## Troubleshooting

### Common Issues and Solutions

#### Installation Problems

**Issue**: `Permission denied` when running install.sh  
**Solution**: Ensure the script has execution permissions with `chmod +x install.sh`

**Issue**: Missing dependencies  
**Solution**:

- For Debian/Ubuntu Linux:
  ```bash
  apt-get update && apt-get install -y curl tar git lsof
  ```
- For macOS:
  ```bash
  brew install curl git lsof
  ```
  **Issue**: `ulimit` error on macOS  
  **Solution**: The installer sets file descriptor limits. If you encounter issues, manually set:

```bash
ulimit -n 10000
```

**Issue**: Installation fails with network-related errors  
**Solution**: Check your internet connection and any firewall or proxy settings that might block downloads from GitHub or model repositories.

#### Node Startup Problems

**Issue**: Port already in use
**Solution**: Check if another program is using the default port:

```bash
# Check if port 8080 is in use
lsof -i :8080
# Stop the node and change the port
gaianet config --port 8081
```

**Issue**: Model download failed
**Solution**: Verify your internet connection and model URLs in config.json

#### Vector Database Issues

**Issue**: Qdrant starts but crashes shortly after
**Solution**: Check Qdrant logs and ensure enough disk space:

```bash
tail -f ~/gaianet/log/start-qdrant.log
df -h
```

### Getting Help

If you encounter an issue not covered here:

1. Check the [GitHub Issues](https://github.com/GaiaNet-AI/gaianet-node/issues) for similar problems
2. Join our community discussions in [GitHub Discussions](https://github.com/GaiaNet-AI/gaianet-node/discussions)
3. For urgent issues, contact the maintainers directly

[🔝 Back to top](#table-of-contents)

## License

Gaianet node is [GPL 3.0 licensed](https://github.com/Gaianet-AI/gaianet-node/blob/main/LICENSE).
