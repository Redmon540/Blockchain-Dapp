const Token = artifacts.require("TOKEN");

module.exports = function(deployer) {
    deployer.deploy(Token, 1000000);
}


