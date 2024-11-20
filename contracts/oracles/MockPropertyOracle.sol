// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract MockPropertyOracle {
    mapping(address => bool) private propertyRecords;
    address private admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can modify records");
        _;
    }

    // Admin can set mock property ownership data
    function setPropertyRecord(address owner, bool hasProperty) external onlyAdmin {
        propertyRecords[owner] = hasProperty;
    }

    // This simulates an oracle query
    function verifyOwnership(address claimed_owner) external view returns (bool) {
        return propertyRecords[claimed_owner];
    }
}
