// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MiniWallet {
    address admin;
    bool public savingActive;
    ERC20 savingToken;

    struct Wallet {
        address walletOwner;
        uint walletBalance;
        uint savingDuration;
    }

    mapping(address => Wallet) savingWallet;

    modifier adminRestricted() {
        require(
            msg.sender == admin,
            "Function call is restricted to contract admin"
        );
        _;
    }

    event Saved(uint amount, uint savingDuration, string message);
    event SavingUpdated(uint amount, string message);

    modifier isSavingActive() {
        require(savingActive == true, "Saving inactive");
        _;
    }

    modifier checkAmountAndBalance(uint256 _amount) {
        require(_amount > 0, "Can't save zero tokens");
        require(
            savingToken.balanceOf(msg.sender) >= _amount,
            "Current token balance less than _amount"
        );
        _;
    }

    constructor(ERC20 _savingToken) {
        admin = msg.sender;
        savingToken = _savingToken;
    }

    /**
     * @dev Only first time users can call this function. To increase savings, the addSaving() function should be called
     * @notice Allow users to create a wallet and save their savingTokens on the platform
     * @param _amount The amount of savingTokens to save to wallet
     * @param _savingDurationInWeeks The number of weeks to save the tokens on the platform
     */
    function save(
        uint256 _amount,
        uint256 _savingDurationInWeeks
    ) external isSavingActive checkAmountAndBalance(_amount) {
        require(
            _savingDurationInWeeks > 1,
            "Saving duration must be more than 1 week"
        );
        Wallet storage wallet = savingWallet[msg.sender];
        require(
            wallet.walletBalance == 0,
            "You already have a balance saved on the dapp."
        );

        savingToken.transferFrom(msg.sender, address(this), _amount);

        wallet.savingDuration =
            block.timestamp +
            (_savingDurationInWeeks * 1 weeks);
        wallet.walletOwner = msg.sender;
        wallet.walletBalance += _amount;

        emit Saved(
            _amount,
            _savingDurationInWeeks,
            "Tokens saved successfully"
        );
    }

    /**
     * @dev Only existing wallets can use this function
     * @notice Allow users that own existing wallets to increase their savings
     * @param _amount The amount of savingTokens to deposit to wallet
     */
    function addSaving(
        uint256 _amount
    ) external isSavingActive checkAmountAndBalance(_amount) {
        Wallet storage wallet = savingWallet[msg.sender];
        require(wallet.walletBalance > 0, "You have not saved before.");

        SafeERC20.safeTransferFrom(
            savingToken,
            msg.sender,
            address(this),
            _amount
        );

        wallet.walletBalance += _amount;

        emit SavingUpdated(
            wallet.walletBalance,
            "Successfully saved more tokens."
        );
    }

    /**
     * @dev Users can only withdraw after savingDuration has been reached or exceeded
     * @notice Allow users to withdraw their funds stored in their wallets
     * @param _amount The amount of savingTokens to withdraw
     */
    function withdraw(uint256 _amount) external {
        Wallet storage wallet = savingWallet[msg.sender];
        require(msg.sender == wallet.walletOwner, "Caller not wallet owner.");
        require(
            wallet.walletBalance >= _amount,
            "_amount greater than balance."
        );

        if (block.timestamp >= wallet.savingDuration) {
            wallet.walletBalance = wallet.walletBalance - _amount;
            SafeERC20.safeTransfer(savingToken, msg.sender, _amount);
        } else {
            revert("Saving duration not elapsed");
        }
    }

    function viewWalletBalance() external view returns (uint balance) {
        return savingWallet[msg.sender].walletBalance;
    }

    function activateSaving(bool saveStatus) external adminRestricted {
        savingActive = saveStatus;
    }
}
