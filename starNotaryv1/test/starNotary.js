//Importing smart Contract ABI (JSON representation of contract)
const StarNotary = artifacts.require('StarNotary')

var accounts;
var owner;

//Calling and Initializing the StarNotary Smart Contract
contract('StarNotary', async (accs) => {
    accounts = accs;
    owner = accounts[0];
})

//Test Case, trying to return starName property initialized by constructor
it('has correct name', async () => {
    let instance = await StarNotary.deployed();
    let starName = await instance.starName.call();
    assert(starName === "Gremblin Star", "Star Return Correctly");
})

it('can be claimed', async () => {
    let instance = await StarNotary.deployed();
    await instance.claimStar();
    let starOwner = await instance.starOwner.call();
    assert.equal(starOwner, owner);
})

it('can change ownership', async () => {
    let instance = await StarNotary.deployed();
    let secondUser = accounts[1];
    await instance.claimStar({from: owner});
    let starOwner = await instance.starOwner.call();
    assert.equal(starOwner, owner);
    await instance.claimStar({from: secondUser});
    starOwner = await instance.starOwner.call();
    assert.equal(starOwner, secondUser);
})

