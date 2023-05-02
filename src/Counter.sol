// SPDX-License-Identifier: MIT
// This line specifies the license for the contract code, in this case the MIT license

pragma solidity ^0.8.13;
// This line specifies the Solidity version used to compile the code. 
// The caret (^) symbol means that the code should be compatible with Solidity versions greater than or equal to 0.8.13, but less than 0.9.0

contract Counter {
    uint256 public number;
    // This line declares a public unsigned integer variable called 'number'

    function setNumber(uint256 newNumber) public {
        // This line declares a public function called 'setNumber' which takes an unsigned integer argument called 'newNumber'
        number = newNumber;
        // This line sets the 'number' variable to the value of the 'newNumber' argument
    }

    function increment() public {
        // This line declares a public function called 'increment'
        number++;
        // This line increments the value of the 'number' variable by 1
    }
}
