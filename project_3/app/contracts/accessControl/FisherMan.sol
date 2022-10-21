pragma solidity ^0.5.1;

//Import the Library 'Roles'
import "./Roles.sol";

contract FisherMan {
    using Roles for Roles.Role;

    //Define main events, for adding and removing.
    event FisherAdded(address indexed account);
    event FisherRemoved(address indexed account);

    //Define a struct 'fisherMan' by inheriting from 'Roles' library, struct Role.
    Roles.Role private fisher;

    //Make the address that deploys this contract the 1st fisherMan.
    constructor() public {
        _addFisher(msg.sender);
    }

    //Checks if msg.sender has the appropiate role.
    modifier onlyFisher() {
        require(isFisher(msg.sender));
        _;
    }

    //Check if account has Fisher role.
    function isFisher(address account) public view returns(bool){
        return fisher.has(account);
    } 

    //Add Fisher role permissions to account
    function addFisher(address account) public onlyFisher {
        _addFisher(account);
    }

    //Renounce to the Fishers Role
    function renounceFisher() public {
        _removeFisher(msg.sender);
    }

    //Internal function '_addFisher' to add this role, called by 'addFisher'.
    function _addFisher(address account) internal {
        fisher.add(account);
        emit FisherAdded(account);
    }

    //Internal function '_removeFisher' to remove this role, called by 'renounceFisher'.
    function _removeFisher(address account) internal {
        fisher.remove(account);
        emit FisherRemoved(account);
    }
}
