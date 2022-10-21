pragma solidity >=0.4.22 <0.7.0;

contract stringsContract {
    
    function getStringIndex(string memory str, uint8 index) public pure returns(byte) {
        
        bytes memory temp = bytes(str);
        return temp[index];
        
    }
}
