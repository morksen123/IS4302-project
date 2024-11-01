// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract DataStorageBase {
    address private ownerContract;
    mapping(address => bool) private authorizedContracts;

    constructor() public {
        ownerContract = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerContract, "Only owner can call contract");
        _;
    }

    modifier onlyAuthorized() {
        require(authorizedContracts[msg.sender], "Only authorized contracts");
        _;
    }

    function addAuthorizedContract(address contractAddress) external onlyOwner {
        authorizedContracts[contractAddress] = true;
    }

    function removeAuthorizedContract(address contractAddress) external onlyOwner {
        authorizedContracts[contractAddress] = false;
    }
}
