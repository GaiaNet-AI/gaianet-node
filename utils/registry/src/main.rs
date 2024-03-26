use clap::{Arg, Command};
use serde_json::{Map, Value, json};
use std::fs::File;
use std::io::prelude::*;
use std::io::Read;
pub mod ether_lib;
use ether_lib::*;
use ethers_core::abi::Token;
use ethers_signers::{Signer, LocalWallet};
use ethers_core::types::{H160, U256};
use const_hex::ToHexExt;
use std::str::FromStr;

fn parse_config(path: &str) -> Map<String, Value>{
    let mut file = File::open(path).unwrap();
    let mut data = String::new();
    file.read_to_string(&mut data).unwrap();
    let config = serde_json::from_str(data.as_str()).unwrap();
    return config;
}

fn save_config(path: &str, content: String) {
    let mut output = File::create(path).unwrap();
    output.write_all(content.as_bytes()).unwrap();
}

#[tokio::main(flavor = "current_thread")]
async fn main() {
    let matches = Command::new("")
        .version("1.0")
        .about("An example CLI")
        .disable_help_subcommand(true)
        // .subcommand(
        //     Command::new("generate")
        //         .about("Generates private key")
        //         .arg(Arg::new("config")
        //             .long("config")
        //             .value_name("FILE")
        //             .help("Sets a custom config file")
        //             .required(false))
        // )
        .arg(Arg::new("status")
            .long("status")
            .value_name("status")
            .help("Setting status")
            .required(false)
        )
        // .arg_required_else_help(true)
        .get_matches();

    // Configuration
    let path = "./config.json";
    let chain_id = 18;
    let rpc_node_url = "https://mainnet.cybermiles.io";
    let contract_address = "0x44Ed2acE4a5D7f939efbe283966ffE10f57A8040";

    let mut config = parse_config(path);
    if let Some(status) = matches.get_one::<String>("status") {
        let wallet: LocalWallet = config["private_key"]
        .to_string()
        .trim_matches('"')
        .to_string()
        .parse::<LocalWallet>()
        .unwrap()
        .with_chain_id(chain_id);

        let status = if status == "0" {
            false
        } else if status == "1" {
            true
        } else {
            panic!("Status must be 0 or 1");
        };
        let data = create_contract_call_data("updateNode", vec![
            Token::Address(H160::from_str(config["address"].to_string().trim_matches('"')).unwrap()),
            Token::String(config["address"].to_string().trim_matches('"').to_string()),
            Token::String(config["description"].to_string().trim_matches('"').to_string()),
            Token::String(config["public_url"].to_string().trim_matches('"').to_string()), 
            Token::Bool(status)Create a Rust program to update the registration smart contractCreate a Rust program to update the registration smart contract
        ]).unwrap();
        let params = json!([wrap_transaction(&rpc_node_url, chain_id, wallet, H160::from_str(&contract_address).unwrap().into(), data, U256::from(0)).await.unwrap().as_str()]);
        let resp =json_rpc(&rpc_node_url, "eth_sendRawTransaction", params).await.expect("Failed to send raw transaction.");
        println!("Send transaction: {}", resp);
    } else {
        if !config.contains_key("private_key") || !config.contains_key("address") {
            let (address, private_key) = generate_key();
            config.insert("address".to_string(), Value::from(address.encode_hex_with_prefix()));
            config.insert("private_key".to_string(), Value::from(format!("0x{}", private_key)));
            save_config(path, serde_json::to_string_pretty(&config).unwrap());
            println!("Generate new key.");
        }else{
            println!("You already have a private key.")
        }
    }
}
