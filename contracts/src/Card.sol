// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Card {
    uint256 public id;
    string public name;
    address public owner;

    constructor(uint256 _id, string memory _name, address _owner) {
        id = _id;
        name = _name;
        owner = _owner;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}
