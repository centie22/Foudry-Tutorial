// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/savings.sol";

contract CounterTest is Test {
    miniWallet public MiniWallet;
    address Alice;

    receive() external payable {}
    
    function setUp() public {
        MiniWallet = new miniWallet();
    }

    // function testActivateSaving() public {
    //     MiniWallet.activateSaving(true);
    //     assertEq(MiniWallet.savingActive(), true);
    // }

    function testSave() public {
        MiniWallet.activateSaving(true);
        Alice = address(0x2);
       vm.startPrank(address(Alice));
        payable(address(Alice)).transfer(1 ether);
        MiniWallet.save(1, 4);
        MiniWallet.viewWalletBalance();
        MiniWallet.addSaving(2);
        MiniWallet.viewWalletBalance();
        vm.stopPrank();
    }
}


/*  . first, I wanna activate saving
    . second, impersonate addresses Alice and Bob to save, add saving and withdraw
    . I also wanna deactivate saving as owner and use address of Bob to try to deactivate saving for the test to fail
    . After deactivating, then I will try to use Alice's address to add saving.
    . View wallet balance of Alice

    No, first, I want to fork mainnet then activate it.
    Next get an address that has CELO, the CELO contract address and addresses to impersonate
    I also wanna activate saving and withdraw, then save with some addresses and attempt to withdraw.
    Deactive and try to save
    prank another address to withdraw.
 */