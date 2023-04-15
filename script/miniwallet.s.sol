// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import "src/savings.sol";

contract walletScript is Script{
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        miniWallet MiniWallet = new miniWallet();
        vm.stopBroadcast();
    }

}