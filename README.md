# Foundry: Deploying And Forking Mainnet With Foundry 

## Introduction
In this tutorial, I will take you through how to deploy smart contract and fork the Celo Alfajores testnet with **Foundry**.
Some of us smart contract developers danced the bhangra when Foundry was released. But what is foundry?
**Foundry is a convenient and comprehensive suite of tools for building and deploying decentralized applications (DApps) on the blockchain**. It is convenient because it lets you write tests in Solidity instead of Javascript, which is the scripting and testing language of the Hardhat toolkit.

At the end of this tutorial, you will be able to fork mainnet or testnet for testing and deploy a smart contract using the foundry toolkit. 

## Table Of Contents 
* Introduction
- Prerequisites
- Requirements
* Smart Contract
- Installation
- Code
- Testing
    * Fork Celo alfajores testnet
    * Test smart contract
    * Deploy smart contract
* Conclusion
* References

## Prerequisites 
Before going ahead with the tutorial, it is important for you to have a good understanding of 
* solidity 
* smart contracts 
* The EVM. 

## Requirements
* Foundry
* IDE

## Smart Contract
We will be writing a simple savings smart contract which we will test and deploy. Let's get into it.

### Installations
```sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract miniWallet{
address admin;
bool public savingActive;
ERC20 savingToken;

struct wallet {
    address walletOwner;
    uint walletBalance;
    uint savingDuration;
}

mapping (address => wallet) savingWallet;

modifier adminRestricted() {
    require(msg.sender == admin, "Function call is restricted to contract admin");
    _;
}

event saved(uint amount, uint savningDuration, string message);
event savingUpdated(uint amount, string message);

constructor (ERC20 _savingToken){
    admin = msg.sender;
    savingToken = _savingToken;
}

function save (uint _amount, uint savingDurationInWeeks) external {
    require(msg.sender != address(0), "zero address can't call function");
    require (savingActive == true, "Saving inactive");
    require(_amount > 0, "Can't save zero ether");
    require(savingDurationInWeeks > 1, "Saving duration must be more than 1 week");
    require (savingToken.balanceOf(msg.sender) >= _amount, "Current token balance less than _amount");
    wallet storage Wallet = savingWallet[msg.sender];
    Wallet.walletOwner = msg.sender;
    Wallet.walletBalance += _amount;
    Wallet.savingDuration = (block.timestamp + savingDurationInWeeks) * 1 weeks;
    emit saved(_amount, savingDurationInWeeks, "Tokens saved successfully");
}

function addSaving (uint _amount) external {
    require(savingActive == true, "Saving inactive");
    wallet storage Wallet = savingWallet[msg.sender];
    require(Wallet.walletBalance > 0, "You have not saved before.");
    require(_amount > 0, "Can't save zero tokens");
    require(savingToken.balanceOf(msg.sender) >= _amount, "Insufficient token balance.");
    Wallet.walletBalance += _amount;
    uint theBalance = Wallet.walletBalance;
    emit savingUpdated(theBalance, "Successfully saved more tokens.");
}

function withdraw(uint _amount) external{
    wallet storage Wallet = savingWallet[msg.sender];
    require (msg.sender == Wallet.walletOwner, "Caller not wallet owner.");
    require(Wallet.walletBalance >= _amount, "_amount greater than balance.");
    if (block.timestamp >= Wallet.savingDuration) {
        uint newBalance = Wallet.walletBalance - _amount;
        Wallet.walletBalance = newBalance;
       savingToken.transferFrom(address(this), msg.sender, _amount);
    } else {
       revert ("Saving duration not elapsed");
    }
}

function viewWalletBalance () external view returns (uint balance){
     wallet storage Wallet = savingWallet[msg.sender];
     balance = Wallet.walletBalance;
     return balance;
}

function activateSaving(bool saveStatus) external adminRestricted{
    savingActive = saveStatus;
}


}
```