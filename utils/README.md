A collection of cargo projects for util programs needed by the node

## Build

Using cargo to build the Rust code.
```
cargo build --target wasm32-wasi --release
```
## Run
Using Wasmedge to run wasm, `--dir` is the config file path.

The program will check if the config has the `address` and `private_key` fields, if not it will generate a new one. 
```
wasmedge --dir .:. target/wasm32-wasi/release/utils.wasm
```

Providing a `status` argument will update the node using the config file and set status as your argument.
```
wasmedge --dir .:. target/wasm32-wasi/release/utils.wasm --status 0
```