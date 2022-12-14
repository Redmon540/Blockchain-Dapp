pragma solidity ^0.5.1;

/*
    @title Roles
    @dev Library for managing addresses assigned to a Role.
*/

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    //@dev give an account access to this role
    function add(Role storage role, address account) internal{
        require(account != address(0));
        require(!has(role,account));

        role.bearer[account] = true;
    }

    //@dev remove account's access to this role
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role,account));

        role.bearer[account] = false;
    }

    //@dev check if an account has a role
    //@return bool

    function has(Role storage role, address account) internal view returns(bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}
