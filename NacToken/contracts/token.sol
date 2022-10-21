pragma solidity >=0.4.22;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract TOKEN is ERC20 {

    constructor(uint256 initialSupply) ERC20("NAC","NAC") public {
         require(initialSupply > 0);
        _mint(msg.sender, initialSupply);
    } 
}
