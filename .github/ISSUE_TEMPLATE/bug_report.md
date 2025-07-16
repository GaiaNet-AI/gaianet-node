---
name: 🐛 Bug Report
about: Report critical issues in GaiaNet Node implementation
title: "[BUG] "
labels: "bug, severity:critical, needs-triage"
assignees: ""
---

## 🧪 Describe the Issue

<!--
  Clear description of the problem with technical specificity.
  Check all applicable impact categories.
-->

- [ ] Node crash/unrecoverable state
- [ ] Consensus failure
- [ ] Block synchronization failure
- [ ] P2P networking issue
- [ ] RPC/API malfunction
- [ ] Transaction processing error
- [ ] Memory leak/resource exhaustion
- [ ] Cryptographic operation failure
- [ ] Storage corruption
- [ ] Performance degradation
- [ ] Security vulnerability
- [ ] Documentation error
- [ ] Other:

### 🔍 Affected Components

<!-- Check all that apply -->

- [ ] Consensus engine (Tendermint/BFT)
- [ ] State machine
- [ ] P2P networking layer
- [ ] RPC/API interface
- [ ] Storage layer (LevelDB/RocksDB)
- [ ] Cryptography module
- [ ] Smart contract execution
- [ ] CLI commands
- [ ] Monitoring/metrics
- [ ] Deployment scripts
- [ ] Testing framework
- [ ] Documentation

## 📜 Expected Behavior

<!--
  Technical specification of expected behavior:
  - Protocol requirements
  - Expected state transitions
  - Performance benchmarks
-->

### 🛠️ Steps to Reproduce

`bash

# Provide exact CLI commands and environment setup

1. gaianet-node init --chain-id=gaia-testnet-1
2. gaianet-node start --log_level=debug
3. curl -X POST http://localhost:26657 -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"broadcast_tx_sync","params":["..."]}'
4.
