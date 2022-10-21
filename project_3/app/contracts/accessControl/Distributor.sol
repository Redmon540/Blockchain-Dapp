pragma solidity ^0.5.1;

import "./Roles.sol";

contract Distributor {
    using Roles for Roles.Role;

    //Define main events, for adding and removing.
    event DistributorAdded(address indexed account);
    event DistributorRemoved(address indexed account);

    //Define a struct 'Distributor' by inheriting from 'Roles' library, struct Role.
    Roles.Role private distributor;

    //Make the address that deploys this contract the 1st Distributor.
    constructor() public {
        _addDistributor(msg.sender);
    }

    //Checks if msg.sender has the appropiate role.
    modifier onlyDistributor() {
        require(isDistributor(msg.sender));
        _;
    }

    //Check if account has Distributor role.
    function isDistributor(address account) public view returns(bool){
        return distributor.has(account);
    } 

    //Add Distributor role permissions to account
    function addDistributor(address account) public onlyDistributor {
        _addDistributor(account);
    }

    //Renounce to the Distributors Role
    function renounceDistributor() public {
        _removeDistributor(msg.sender);
    }

    //Internal function '_addDistributor' to add this role, called by 'addDistributor'.
    function _addDistributor(address account) internal {
        distributor.add(account);
        emit DistributorAdded(account);
    }

    //Internal function '_removeDistributor' to remove this role, called by 'renounceDistributor'.
    function _removeDistributor(address account) internal {
        distributor.remove(account);
        emit DistributorRemoved(account);
    }

}
