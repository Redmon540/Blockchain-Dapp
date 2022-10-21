pragma solidity >=0.4.24;

contract StarNotary {
    
    string public starName;
    address public starOwner;

    event starClaimed(address owner);

    constructor () public {
        starName = "Gremblin Star";
    }

    function claimStar() public {
        starOwner = msg.sender;
        emit starClaimed(msg.sender);
    }
}
