pragma solidity ^0.5.1;

//Import the Library 'Roles'
import "./Roles.sol";

contract Retailer {
    using Roles for Roles.Role;

    //Define main events, for adding and removing.
    event RetailerAdded(address indexed account);
    event RetailerRemoved(address indexed account);

    //Define a struct 'retailer' by inheriting from 'Roles' library, struct Role.
    Roles.Role private retailer;

    //Make the address that deploys this contract the 1st fisherMan.
    constructor() public {
        _addRetailer(msg.sender);
    }

    //Checks if msg.sender has the appropiate role.
    modifier onlyRetailer() {
        require(isRetailer(msg.sender));
        _;
    }

    //Check if account has Retailer role.
    function isRetailer(address account) public view returns(bool){
        return retailer.has(account);
    } 

    //Add Retailer role permissions to account
    function addRetailer(address account) public onlyRetailer {
        _addRetailer(account);
    }

    //Renounce to the Retailer Role
    function renounceRetailer() public {
        _removeRetailer(msg.sender);
    }

    //Internal function '_addRetailer' to add this role, called by 'addFisher'.
    function _addRetailer(address account) internal {
        retailer.add(account);
        emit RetailerAdded(account);
    }

    //Internal function '_removeRetailer' to remove this role, called by 'renounceFisher'.
    function _removeRetailer(address account) internal {
        retailer.remove(account);
        emit RetailerRemoved(account);
    }
}
