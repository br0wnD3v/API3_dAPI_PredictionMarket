//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PM_Vault is Ownable {
    IERC20 public immutable I_USDC_CONTRACT;

    constructor(address _usdcAddress) {
        I_USDC_CONTRACT = IERC20(_usdcAddress);
    }

    function currentBalance() external view returns (uint256) {
        return I_USDC_CONTRACT.balanceOf(address(this));
    }

    function sendUSDC() external {
        uint256 balance = I_USDC_CONTRACT.balanceOf(address(this));
        I_USDC_CONTRACT.transfer(owner(), balance);
    }
}
