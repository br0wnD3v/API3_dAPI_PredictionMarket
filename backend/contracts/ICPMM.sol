// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface ICPMM {
    function swapTokens(uint amountIn, bool isYesToNo) external;

    function buyNoToken(uint256 amountUSDC, address caller) external;

    function buyYesToken(uint256 amountUSDC, address caller) external;

    function concludePrediction_3(bool winner) external returns (bool);

    function getPriceA() external view returns (uint256);

    function getPriceB() external view returns (uint256);

    function getPriceAInUSDC() external view returns (uint256);

    function getPriceBInUSDC() external view returns (uint256);
}
