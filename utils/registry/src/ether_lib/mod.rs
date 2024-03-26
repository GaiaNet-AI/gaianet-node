use serde_json::Value;
use serde_json::json;
use std::collections::HashMap;
use std::str::FromStr;
use ethers_signers::{LocalWallet, Signer, MnemonicBuilder, coins_bip39::English};
use ethers_core::types::{NameOrAddress, Bytes, H160, U256, U64, TransactionRequest, transaction::eip2718::TypedTransaction};
use ethers_core::abi::{Abi, Function, Token};
use ethers_core::utils::hex;
use ethers_core::rand;

type Result<T> = std::result::Result<T, Box<dyn std::error::Error + Send + Sync>>;

pub fn create_contract_call_data(name: &str, tokens: Vec<Token>) -> Result<Bytes> {
    
    let contract_abi: &str = include_str!("../abi.json");
    let abi: Abi = serde_json::from_str(&contract_abi).unwrap();
    let function: &Function = abi
        .functions()
        .find(|&f| f.name == name)
        .ok_or("Function not found in ABI")?;

    let data = function.encode_input(&tokens).unwrap();

    Ok(Bytes::from(data))
}

pub async fn wrap_transaction(rpc_node_url: &str, chain_id: u64, wallet: LocalWallet, address_to: NameOrAddress, data: Bytes, value: U256) -> Result<String> {
	let address_from = wallet.address();
	let nonce = get_nonce(&rpc_node_url, format!("{:?}", wallet.address()).as_str()).await.unwrap();
	let estimate_gas = get_estimate_gas(&rpc_node_url, format!("{:?}", address_from).as_str(), 
										format!("{:?}", address_to.as_address().expect("Failed to transfer address")).as_str(), 
										format!("0x{:x}", value).as_str(), format!("{:}", data).as_str())
										.await
										.expect("Failed to gat estimate gas.") * U256::from(12) / U256::from(10);
	
	let tx: TypedTransaction = TransactionRequest::new()
	.from(address_from)
	.to(address_to) 
	.nonce::<U256>(nonce.into())
	.gas_price::<U256>(get_gas_price(&rpc_node_url).await.expect("Failed to get gas price.").into())
	.gas::<U256>(estimate_gas.into())
	.chain_id::<U64>(chain_id.into())
	.data::<Bytes>(data.into())
	.value(value).into();    
	
	
	let signature = wallet.sign_transaction(&tx).await.expect("Failed to sign.");
	

	Ok(format!("0x{}", hex::encode(tx.rlp_signed(&signature))))
}

pub async fn get_gas_price(rpc_node_url: &str) -> Result<U256> {
	let params = json!([]);
	let result = json_rpc(rpc_node_url, "eth_gasPrice", params).await.expect("Failed to send json.");
	
	Ok(U256::from_str(&result)?)
}

pub async fn get_nonce(rpc_node_url: &str, address: &str) -> Result<U256> {
	let params = json!([address, "pending"]);
	let result = json_rpc(rpc_node_url, "eth_getTransactionCount", params).await.expect("Failed to send json.");
	
	Ok(U256::from_str(&result)?)
}

pub async fn get_estimate_gas(rpc_node_url: &str, from: &str, to: &str, value: &str, data: &str) -> Result<U256> {
	let params = json!([{"from": from, "to": to, "value":value, "data":data}]);
	let result = json_rpc(rpc_node_url, "eth_estimateGas", params).await.expect("Failed to send json.");
	
	Ok(U256::from_str(&result)?)
}

pub async fn json_rpc(url: &str, method: &str, params: Value) -> Result<String> {
	let client = reqwest::Client::new();
	let res = client
		.post(url)
		.header("Content-Type","application/json")
		.body(json!({
			"jsonrpc": "2.0",
			"method": method,
			"params": params,
			"id": 1
		}).to_string())
		.send()
		.await?;

	let body = res.text().await?;
	let map: HashMap<String, serde_json::Value> = serde_json::from_str(body.as_str())?;
	if !map.contains_key("result"){
		println!("{} request body: {:#?}", method, json!({
			"jsonrpc": "2.0",
			"method": method,
			"params": params,
			"id": 1
		}));
		println!("{} response body: {:#?}", method, map);
		println!("{} request body: {:#?}", method, json!({
			"jsonrpc": "2.0",
			"method": method,
			"params": params,
			"id": 1
		}));
		println!("{} response body: {:#?}", method, map);
	}
	Ok(serde_json::to_string(&map["result"]).expect("Failed to parse str.").trim_matches('"').to_string())
}

pub fn generate_key() -> (H160, String) {
    let wallet;

    let mut rng = rand::thread_rng();
    wallet = MnemonicBuilder::<English>::default()
    .word_count(24)
    .derivation_path("m/44'/60'/0'/2/1")
    .unwrap()
    .build_random(&mut rng)
    .unwrap();   

    return (wallet.address(), hex::encode(wallet.signer().to_bytes())) 
}