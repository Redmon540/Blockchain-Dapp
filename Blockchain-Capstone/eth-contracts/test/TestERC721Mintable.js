var ERC721MintableComplete = artifacts.require('CustomERC721Token');

contract('TestERC721Mintable', accounts => {

    const account_one = accounts[0];
    const account_two = accounts[1];

    describe('match erc721 spec', function () {
        beforeEach(async function () { 
            this.contract = await ERC721MintableComplete.new({from: account_one});

            // TODO: mint multiple tokens
            this.contract.mint(accounts[2],1);
            this.contract.mint(accounts[3],2);
            this.contract.mint(accounts[3],3);
            this.contract.mint(accounts[4],4);
        })

        it('should return total supply', async function () { 
            assert.equal(await this.contract.totalSupply(), 4, "Total Supply incorrect");
        })

        it('should get token balance', async function () { 
            assert.equal(await this.contract.balanceOf(accounts[3]),2, "Incorrect balance");
        })

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async function () { 
            assert.equal(await this.contract.tokenURI(2),'https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/2',
            "Incorrect URI");
        })

        it('should transfer token from one owner to another', async function () { 
            await this.contract.transferFrom(accounts[3],accounts[4],2,{from: accounts[3]});
            let balance3 = await this.contract.balanceOf(accounts[3]);
            let balance4 = await this.contract.balanceOf(accounts[4]);
            assert.equal(balance3,1, 'Balance incorrect for account 2');
            assert.equal(balance4,2, 'Balance incorrect for account 4');
            let token1 = await this.contract.tokenOfOwnerByIndex(accounts[4],0);
            let token2 = await this.contract.tokenOfOwnerByIndex(accounts[4],1);
            assert.equal(token1,4, 'Incorrect token');
            assert.equal(token2,2, 'Incorrect token');
        })
    });

    describe('have ownership properties', function () {
        beforeEach(async function () { 
            this.contract = await ERC721MintableComplete.new({from: account_one});
        })

        it('should fail when minting when address is not contract owner', async function () { 
            let fail = false;
            try {
                await this.contract.mint(accounts[2],5,{from: account_two});
            } catch(e) {
                fail = true;
            }
            assert.equal(fail, true, "Minting fails when not contract owner")
        })

        it('should return contract owner', async function () { 
            assert.equal(await this.contract.getOwner(), account_one, "Doesn't return contract owner");
        })

    });
})
