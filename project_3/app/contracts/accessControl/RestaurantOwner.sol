pragma solidity ^0.5.1;

import "./Roles.sol";

contract RestaurantOwner {
    using Roles for Roles.Role;

    //Define main events, for adding and removing.
    event BuyerAdded(address indexed account);
    event BuyerRemoved(address indexed account);

    //Define a struct 'Buyer' by inheriting from 'Roles' library, struct Role.
    Roles.Role private buyer;

    //Make the address that deploys this contract the 1st Buyer.
    constructor() public {
        _addBuyer(msg.sender);
    }

    //Checks if msg.sender has the appropiate role.
    modifier onlyBuyer() {
        require(isBuyer(msg.sender));
        _;
    }

    //Check if account has Buyer role.
    function isBuyer(address account) public view returns(bool){
        return buyer.has(account);
    } 

    //Add Buyer role permissions to account
    function addBuyer(address account) public onlyBuyer {
        _addBuyer(account);
    }

    //Renounce to the Buyers Role
    function renounceBuyer() public {
        _removeBuyer(msg.sender);
    }

    //Internal function '_addBuyer' to add this role, called by 'addBuyer'.
    function _addBuyer(address account) internal {
        buyer.add(account);
        emit BuyerAdded(account);
    }

    //Internal function '_removeBuyer' to remove this role, called by 'renounceBuyer'.
    function _removeBuyer(address account) internal {
        buyer.remove(account);
        emit BuyerRemoved(account);
    }

}
