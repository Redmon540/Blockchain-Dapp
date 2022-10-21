pragma solidity >=0.4.22 <0.7.0;

contract Modifier {
    uint public minimum_bid = 1 ether;
    
    function bid () public payable returns (bool) {
        require(msg.value >= minimum_bid);
        return true;
    }
}
