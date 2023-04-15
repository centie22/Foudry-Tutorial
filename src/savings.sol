// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract miniWallet{
address admin;
bool public savingActive;
address CELO;

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
event saveingUpdated(uint amount, string message);
constructor (address _celo){
    admin = msg.sender;
    CELO = _celo;
}

function save (uint _amount, uint savingDurationInWeeks) external payable{
    require(msg.sender != address(0), "zero address can't call function");
    require (savingActive == true, "Saving inactive");
    require(_amount > 0, "Can't save zero ether");
    require (CELO.balanceOf(msg.sender) >= _amount, "Current ether balance less than _amount");
    wallet storage Wallet = savingWallet[msg.sender];
    Wallet.walletOwner = msg.sender;
    Wallet.walletBalance += _amount;
    Wallet.savingDuration = (block.timestamp + savingDurationInWeeks) * 1 weeks;
    emit saved(_amount, savingDurationInWeeks, "Ether saved successfully");
}

function addSaving (uint _amount) external payable{
    require(savingActive == true, "Saving inactive");
    require(_amount > 0, "Can't save zero ether");
    wallet storage Wallet = savingWallet[msg.sender];
    Wallet.walletBalance += _amount;
    uint theBalance = Wallet.walletBalance;
    emit saveingUpdated(theBalance, "Successfully saved more ether.");
}

function withdraw(uint _amount) external{
    wallet storage Wallet = savingWallet[msg.sender];
    require (msg.sender == Wallet.walletOwner, "Caller not wallet owner.");
    if (block.timestamp >= Wallet.savingDuration) {
        uint newBalance = Wallet.walletBalance - _amount;
        Wallet.walletBalance = newBalance;
       payable (Wallet.walletOwner).transfer(_amount);
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

    receive () external payable {}
}