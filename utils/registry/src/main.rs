use clap::{Arg, Command};
use serde_json::{json, Map, Value};
use std::fs::File;
use std::io::prelude::*;
use std::io::Read;
pub mod ether_lib;
use const_hex::ToHexExt;
use eth_keystore;
use ether_lib::*;
use ethers_core::abi::Token;
use ethers_core::rand;
use ethers_core::types::{H160, U256};
use ethers_signers::{LocalWallet, Signer};
use passwords::PasswordGenerator;
use std::path::Path;
use std::str::FromStr;

fn parse_config(path: &str) -> Map<String, Value> {
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
        .arg(
            Arg::new("status")
                .long("status")
                .value_name("status")
                .help("Setting status")
                .required(false)
                .requires("keystore"),
        )
        .arg(
            Arg::new("keystore")
                .long("keystore")
                .value_name("keystore")
                .help("Keystore path"),
        )
        .arg(
            Arg::new("private_key")
                .long("privateKey")
                .value_name("private_key")
                .help("Private key")
                .required(false),
        )
        // .arg_required_else_help(true)
        .get_matches();

    // Configuration
    let path_node_config = "./config.json";
    let path_nodeid = "./nodeid.json";
    let path_web_config = "./dashboard/config_pub.json";
    let chain_id = 18;
    let rpc_node_url = "https://mainnet.cybermiles.io";
    let contract_address = "0x44Ed2acE4a5D7f939efbe283966ffE10f57A8040";
    let dir = Path::new("");
    let mut rng = rand::thread_rng();
    let pg = PasswordGenerator {
        length: 30,
        numbers: true,
        lowercase_letters: true,
        uppercase_letters: true,
        symbols: false,
        spaces: false,
        exclude_similar_characters: false,
        strict: true,
    };

    let mut node_config = parse_config(path_node_config);
    let mut nodeid = parse_config(path_nodeid);
    if let Some(status) = matches.get_one::<String>("status") {
        let keystore = if nodeid.contains_key("keystore") {
            nodeid["keystore"].to_string().trim_matches('"').to_string()
        } else {
            "keystore.def".to_string()
        };
        let password = if nodeid.contains_key("password") {
            nodeid["password"].to_string().trim_matches('"').to_string()
        } else {
            panic!("You need provide password.");
        };
        let private_key;
        match eth_keystore::decrypt_key(dir.join(keystore), password.as_bytes()) {
            Ok(_private_key) => private_key = String::from_utf8(_private_key).unwrap(),
            Err(_err) => panic!("Can not decrypt key."),
        }
        let wallet: LocalWallet = private_key
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

        let mut public_url = "https://".to_owned();
        public_url.push_str(&node_config["address"].to_string());
        public_url.push_str("/");
        public_url.push_str(&node_config["domain"].to_string());

        let data = create_contract_call_data(
            "updateNode",
            vec![
                Token::Address(
                    H160::from_str(nodeid["address"].to_string().trim_matches('"')).unwrap(),
                ),
                Token::String(nodeid["address"].to_string().trim_matches('"').to_string()),
                Token::String(
                    node_config["description"]
                        .to_string()
                        .trim_matches('"')
                        .to_string(),
                ),
                Token::String(public_url),
                Token::Bool(status),
            ],
        )
        .unwrap();
        let params = json!([wrap_transaction(
            &rpc_node_url,
            chain_id,
            wallet,
            H160::from_str(&contract_address).unwrap().into(),
            data,
            U256::from(0)
        )
        .await
        .unwrap()
        .as_str()]);
        let resp = json_rpc(&rpc_node_url, "eth_sendRawTransaction", params)
            .await
            .expect("Failed to send raw transaction.");
        println!("Send transaction: {}", resp);
    } else {
        if !nodeid.contains_key("address") {
            let (address, private_key) = match matches.get_one::<String>("private_key") {
                Some(private_key) => (
                    private_key.parse::<LocalWallet>().unwrap().address(),
                    private_key.clone(),
                ),
                _ => generate_key(),
            };

            let password = if nodeid.contains_key("password") {
                nodeid["password"].to_string().trim_matches('"').to_string()
            } else {
                let password = pg.generate_one().unwrap();
                nodeid.insert("password".to_string(), Value::from(password.clone()));
                password
            };
            let name = eth_keystore::encrypt_key(
                &dir,
                &mut rng,
                &(private_key.as_bytes()),
                password.as_bytes(),
                None,
            )
            .unwrap();
            nodeid.insert(
                "address".to_string(),
                Value::from(address.encode_hex_with_prefix()),
            );
            nodeid.insert(
                "keystore".to_string(),
                Value::from(name.clone()),
            );
            save_config(path_nodeid, serde_json::to_string_pretty(&nodeid).unwrap());
            println!("Generate new key storing in {:?}.", dir.join(name));
        } else {
            println!("You already have a private key.")
        }

        // Put the address in node config
        node_config["address"] = nodeid["address"].clone();
        save_config(path_node_config, serde_json::to_string_pretty(&node_config).unwrap());
        // Save a public copy for the web site
        save_config(path_web_config, serde_json::to_string_pretty(&node_config).unwrap());
    }
}
