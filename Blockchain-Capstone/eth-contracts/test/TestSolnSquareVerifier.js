// Test if a new solution can be added for contract - SolnSquareVerifier

// Test if an ERC721 token can be minted for contract - SolnSquareVerifier
const truffleAssert = require('truffle-assertions')
var SolnSquareVerifier = artifacts.require('./SolnSquareVerifier');
var proof = require('../../zokrates/code/square/proof');

contract('SolnSquareVerifier', accounts => {

    const account_one = accounts[0];
    const account_two = accounts[1];

    describe('SolnSquareVerifier test', function () {
        before(async function () {
            this.contract = await SolnSquareVerifier.new({from: account_one});

        })
        it('should add solution amnd emit event', async function () {

          let A = proof.proof.a;
          let B = proof.proof.b;
          let C = proof.proof.c;
          let input = proof.inputs;

          let check = await this.contract.addSolution(A,B,C,input,{from: account_one});
          truffleAssert.eventEmitted(check, 'SolutionAdded');
        })

        it('should mint a token and emit Transfer', async function () {
          let input = proof.inputs;
          let transferTx = await this.contract.mintNFT(input, accounts[1], {from: account_one}) 
          truffleAssert.eventEmitted(transferTx, 'Transfer', (ev) => {
                return (ev.to == accounts[1] && ev.tokenId == 0);
          })
        })
    })
})
