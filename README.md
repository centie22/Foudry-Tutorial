# Foundry: Deploying And Forking Mainnet With Foundry 

## Introduction
Some of us smart contract developers danced the bhangra when Foundry was released. But what is foundry?
**Foundry is a convenient and comprehensive suite of tools for building and deploying decentralized applications (DApps) on the blockchain**. It is convenient because it lets you write tests in Solidity instead of Javascript, which is the scripting and testing language of the Hardhat toolkit.

In this tutorial, I will take you through how to deploy smart contract and fork the Celo Alfajores testnet with **Foundry**. By forking a blockchain, we can test and debug smart contracts in a local environment, which simulates the behaviour of the live blockchain network. 
I decided to do this since I realized there is almost no tutorial on mainnet/testnet forking with foundry available on the internet.

At the end of this tutorial, you will be able to fork mainnet or testnet for testing and deploy a smart contract using the foundry toolkit. 

> This tutorial is focused on those who have some level of experience writing smart contracts with foundry. However, if you are new to foundry, I have listed some resources in the reference section that can help you get familiar with this toolkit.
## Table Of Contents 
* [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Requirements](#requirements)
* [Getting Started](#getting-started)
- [Smart Contract](#smart-contract)
- [Code](#code)
- [Testing](#testing)
    * [Fork Celo alfajores testnet](#fork celo alfajores testnet)
    * [Test smart contract](#write smart contract test)
    * [Deploy smart contract](#deploy smart contract)
* [Conclusion](#conclusion)
* [References](#references)

## Prerequisites 
Before going ahead with the tutorial, it is important for you to have a good understanding of 
* solidity 
* smart contracts 
* The EVM. 

## Requirements
* Infura account
* Foundry
* IDE

### Getting Started
- Clone this repository:
`git clone https://github.com/centie22/Foudry-Tutorial.git`
- Run `forge install` to install all dependencies.
- Open project in IDE.
## Smart Contract
We have `savings.sol` and `token.sol` smart contracts in the `src` folder. The first is a simple savings smart contract that allows users save a particular ERC20 token over a period of time.
The second is the ERC20 saving token used in the savings smart contract. This token has been deployed on the Celo Alfajores chain and to interact with it in testing our savings smart contract, we need to bring the Alfajores testnet to our local environment by forking it.

## Code
#### savings.sol
```sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract MiniWallet{
address admin;
bool public savingActive;
ERC20 savingToken;

struct Wallet {
    address walletOwner;
    uint walletBalance;
    uint savingDuration;
}

mapping (address => Wallet) savingWallet;

modifier adminRestricted() {
    require(msg.sender == admin, "Function call is restricted to contract admin");
    _;
}

event Saved(uint amount, uint savningDuration, string message);
event SavingUpdated(uint amount, string message);

constructor (ERC20 _savingToken){
    admin = msg.sender;
    savingToken = _savingToken;
}

//  function approve(address spender, uint256 amount) external returns (bool) {
//         return savingToken.approve(spender, amount);
//     }

function save(uint256 _amount, uint256 savingDurationInWeeks) external {
    require(msg.sender != address(0), "zero address can't call function");
    require(savingActive == true, "Saving inactive");
    require(_amount > 0, "Can't save zero tokens");
    require(savingDurationInWeeks > 1, "Saving duration must be more than 1 week");
    require(savingToken.balanceOf(msg.sender) >= _amount, "Current token balance less than _amount");
    savingToken.transferFrom(msg.sender, address(this), _amount);

    Wallet storage wallet = savingWallet[msg.sender];
    wallet.savingDuration = block.timestamp + (savingDurationInWeeks * 1 weeks);
    wallet.walletOwner = msg.sender;
    wallet.walletBalance += _amount;

    emit Saved(_amount, savingDurationInWeeks, "Tokens saved successfully");
}


function addSaving(uint256 _amount) external {
    require(savingActive == true, "Saving inactive");

    Wallet storage wallet = savingWallet[msg.sender];
    require(wallet.walletBalance > 0, "You have not saved before.");
    require(_amount > 0, "Can't save zero tokens");
    require(savingToken.balanceOf(msg.sender) >= _amount, "Insufficient token balance.");

    SafeERC20.safeTransferFrom(savingToken, msg.sender, address(this), _amount);

    wallet.walletBalance += _amount;
    uint256 theBalance = wallet.walletBalance;

    emit SavingUpdated(theBalance, "Successfully saved more tokens.");
}

function withdraw(uint256 _amount) external {
    Wallet storage wallet = savingWallet[msg.sender];
    require(msg.sender == wallet.walletOwner, "Caller not wallet owner.");
    require(wallet.walletBalance >= _amount, "_amount greater than balance.");

    if (block.timestamp >= wallet.savingDuration) {
        uint256 newBalance = wallet.walletBalance - _amount;
        wallet.walletBalance = newBalance;
        SafeERC20.safeTransfer(savingToken, msg.sender, _amount);
    } else {
        revert("Saving duration not elapsed");
    }
}

function viewWalletBalance () external view returns (uint balance){
     Wallet storage wallet = savingWallet[msg.sender];
     balance = wallet.walletBalance;
     return balance;
}

function activateSaving(bool saveStatus) external adminRestricted{
    savingActive = saveStatus;
}


}
```

#### token.sol
```sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract token is ERC20("testToken", "tT") {
    constructor () {
        _mint(msg.sender, 1000000000e18);
    } 
}
```

## Testing
