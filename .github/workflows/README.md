# GitHub Actions Workflows

This directory contains GitHub Actions workflows for running and testing GaiaNet nodes.

## Local Testing with `act`

### Prerequisites
- Docker
- [act](https://github.com/nektos/act)
- [act-cache-server](https://github.com/sp-ricard-valverde/github-act-cache-server) (for caching support)

### Apple Silicon Limitations
When running on Apple Silicon (M1/M2) Macs:
1. WasmEdge execution is not fully supported in the Docker container
2. The workflow will run but fail at the WasmEdge initialization step
3. This is a local testing limitation only - deployment to GitHub Actions runners works correctly

### Cache Configuration
The workflow uses GitHub Actions cache to speed up deployments:
1. Cache is tied to commit SHA and runner OS
2. Cached items include:
   - Downloaded binaries
   - Configuration files
   - Model files
3. For local testing, set up cache server:
   ```bash
   # Start cache server
   docker run --rm -p 49152:8080 ghcr.io/sp-ricard-valverde/act-cache-server:latest

   # Configure environment
   cp .env.example .env
   ```

### Running Tests Locally

Copy the .env.example file to .env and set the ACT_CACHE_SERVER_URL environment variable to the URL of the cache server.

```bash
# Basic test
act push

# With debug logging
act push -v

# Force clean run (no cache)
act push --clean
``` 