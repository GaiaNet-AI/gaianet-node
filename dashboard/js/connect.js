async function checkMetaMask() {
  if (!window.ethereum) {
      await Swal.fire({
          icon: 'error',
          title: 'MetaMask not installed!',
          html: `You can install it <a href="https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn"}">here</a>!`,
      })
      return false;
  }

  let err = false;
  const accounts = await window.ethereum.request({ method: "eth_requestAccounts"})
  .catch((e) => {
      if (e.code === 4001) {
          console.log('Please connect to MetaMask!');
          Swal.fire({
              icon: 'error',
              title: 'Oops...',
              text: 'You rejected the connection!',
          })
      } else {
          console.error(e);
          Swal.fire({
              icon: 'error',
              title: 'Oops...',
              text: 'Connection failed!',
          })
      }
      err = true;
  })
  if (err) return false;

  document.getElementById('inputField').value = accounts[0] || '';
  return true;
}


async function checkContract() {
  provider = new ethers.providers.Web3Provider(window.ethereum)
  signer = await provider.getSigner();
  contract = new ethers.Contract(contractAddress, await $.get(contractABI), provider);
}
async function queryContract(address) {
  if(!ethers.utils.isAddress(address)){
    Swal.fire({
      icon: "error",
      title: "Oops...",
      text: "Input must is address!",
    });
    return null;
  }
  node = await _queryContract(address);
  if(node == null){
    Swal.fire({
      title: "The address not exist?",
      text: "Do you want to create?",
      icon: "question"
    });
  }
  return node;
}

async function _queryContract(address, log = true) {
  try {
    node = await contract.queryNode(address);
    console.log(node)
    if(node.creator == "0x0000000000000000000000000000000000000000"){
      return null;
    }
    return node;
  } catch (error) {
    if(log)
      console.log(error);
    return null;
  }
}

async function updateNode(nodeAddress, name, description, url, availability){
  if(availability.toLowerCase() == "true"){
    availability = true;
  }else if(availability.toLowerCase() == "false"){
    availability = false
  }else{
    Swal.fire({
      icon: "error",
      title: "Oops...",
      text: "Availability need is boolean.",
    });
  }
  if(await _queryContract(nodeAddress, true) == null){
    receipt = await contract.connect(signer).createNode(nodeAddress, name, description, url, availability);
  }else{
    receipt = await contract.connect(signer).updateNode(nodeAddress, name, description, url, availability);
  }
  console.log(receipt);
  Swal.fire({
      icon: 'success',
      text: 'Send transaction successful!',
  });
}

// var contract = null;
// var signer = null;
// checkMetaMask()
// checkContract()
