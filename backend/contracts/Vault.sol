//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PM_Vault is Ownable {
    IERC20 public usdcContract;

    constructor(address _usdcAddress) {
        usdcContract = IERC20(_usdcAddress);
    }

    function currentBalance() external view returns (uint256) {
        return usdcContract.balanceOf(address(this));
    }

    function sendUSDC() external {
        uint256 balance = usdcContract.balanceOf(address(this));
        usdcContract.transfer(owner(), balance);
    }
}
