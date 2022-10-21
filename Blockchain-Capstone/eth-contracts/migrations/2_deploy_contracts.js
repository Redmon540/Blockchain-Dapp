// migrating the appropriate contracts
var ERC721Mintable = artifacts.require("./CustomERC721Token");
var SolnSquareVerifier = artifacts.require("./SolnSquareVerifier");
var SquareVerifier = artifacts.require("./Verifier");
module.exports = function(deployer) {
  deployer.deploy(ERC721Mintable);
  deployer.deploy(SolnSquareVerifier);
  deployer.deploy(SquareVerifier);
};
