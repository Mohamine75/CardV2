// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Card {
    uint256 public id;
    string public name;
    address public owner;
    uint public prix;
    bool public availability;
    constructor(uint256 _id, string memory _name, address _owner) {
        id = _id;
        name = _name;
        owner = _owner;
        prix =0;
        availability = false;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
    function changeOwner(address _newOwner) external {
        owner = _newOwner;
    }
    function changeAvailability() external {
        availability = !availability;
    }
    function changePrix(uint _prix) external {
        prix =_prix;
    }
}
