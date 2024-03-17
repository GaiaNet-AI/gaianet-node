document.getElementById('connectBtn').addEventListener('click',async function() {
  document.getElementById('nodeInfo').classList.remove('d-none');
  var contract = null;
  var signer = null;
  checkMetaMask()
  checkContract()
}

document.getElementById('queryBtn').addEventListener('click',async function() {
  console.log("Query")
  const address = document.getElementById('inputField').value;
  const data = await queryContract(address);
  if (data != null) {
    document.getElementById('nameInput').value = data.name || '';
    document.getElementById('descriptionInput').value = data.description || '';
    document.getElementById('urlInput').value = data.url || '';
    document.getElementById('availabilityInput').value = (data.availability == true ? "true" : "false");
  }
  document.getElementById('dynamicForm').classList.remove('d-none');
});

document.getElementById('updateBtn').addEventListener('click', async function() {
  const name = document.getElementById('nameInput').value;
  const description = document.getElementById('descriptionInput').value;
  const url = document.getElementById('urlInput').value;
  const availability = document.getElementById('availabilityInput').value;
  const address = document.getElementById('inputField').value;
  updateNode(address, name, description, url, availability);
});

document.getElementById('createBtn').addEventListener('click', function() {
  document.getElementById('dynamicForm').classList.remove('d-none');
  document.getElementById('nameInput').value = '';
  document.getElementById('descriptionInput').value = '';
  document.getElementById('urlInput').value = '';
  document.getElementById('availabilityInput').value = '';
});

document.getElementById('backBtn').addEventListener('click', function() {
  document.getElementById('inputField').value = '';
  document.getElementById('dynamicForm').classList.add('d-none');
});
