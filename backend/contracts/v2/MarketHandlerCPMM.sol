// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IMarketHandlerCPMM.sol";
import "../interfaces/IERC20.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PM_MarketHandlerCPMM is Context, Ownable, IMarketHandlerCPMM {
    function swapTokenNoWithYes(uint256 _amount) external override {}

    function swapTokenYesWithNo(uint256 _amount) external override {}

    function buyNoToken(uint256 _amount) external override {}

    function buyYesToken(uint256 _amount) external override {}

    function sellNoToken(uint256 _amount) external override {}

    function sellYesToken(uint256 _amount) external override {}

    function concludePrediction_3(bool winner) external override {}
}
