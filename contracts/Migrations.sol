// // SPDX-License-Identifier: MIT
// // pragma solidity >=0.4.22 <0.9.0;
// pragma solidity ^0.8.0;

// contract Migrations {
//     address public owner;
//     uint256 public last_completed_migration;

//     // modifier restricted() {
//     //     if (msg.sender == owner) _;
//     // }

//      modifier restricted() {
//         require(msg.sender == owner, "This function is restricted to the contract's owner");
//         _;
//     }


//     // constructor() public {
//         constructor() {

//         owner = msg.sender;
//     }

//     function setCompleted(uint completed) public restricted {
//         last_completed_migration = completed;
//     }

//     function upgrade(address new_address) public restricted {
//         Migrations upgraded = Migrations(new_address);
//         upgraded.setCompleted(last_completed_migration);
//     }
// }

pragma solidity ^0.8.0;

contract Migrations {
    address public owner;
    uint256 public last_completed_migration;

    // Ensure only the owner can call restricted functions
    modifier restricted() {
        require(msg.sender == owner, "This function is restricted to the contract's owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Set the last completed migration
    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    // Upgrade function to point to a new Migrations contract
    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}


// pragma solidity ^0.8.0;

// contract Migrations {
//     address public owner;

//     constructor() {
//         owner = msg.sender;
//     }
// }
