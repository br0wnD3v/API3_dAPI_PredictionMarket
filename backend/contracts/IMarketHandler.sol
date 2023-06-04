// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IMarketHandler {
    function swapTokenNoWithYes(uint256) external;

    function swapTokenYesWithNo(uint256) external;

    function buyNoToken(uint256) external;

    function buyYesToken(uint256) external;

    function concludePrediction_3(bool winner) external returns (bool);
}
