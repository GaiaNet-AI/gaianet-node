Create the node address and node key during the init process. Update the registry smart contract using the private key for the node status.

## Build

Using cargo to build the Rust code.
```
cargo build --target wasm32-wasi --release
```
## Run

Using Wasmedge to run wasm, `--dir` is the config file path.

The program will check if the config has the `address` fields, if not it will generate a new keystore and using the `password` field in the config file to encrypt.
If you want to use your private key instead of a randomly generated key, you can provide `privateKey` parameter.

```
wasmedge --dir .:. target/wasm32-wasi/release/registry.wasm --privateKey "private key"
```

Providing a `status` argument will update the node using the config file and set status as your argument.
It will use `keystore` and the `password` field in the config file to decrypt the private key.
```
wasmedge --dir .:. target/wasm32-wasi/release/registry.wasm --status 0 --keystore "keystore path"
```
