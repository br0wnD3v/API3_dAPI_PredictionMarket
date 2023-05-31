// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface ICPMM {
    function swapNoForYes(uint256 amountA) external;

    function swapYesForNo(uint256 amountB) external;

    function buyNoWithUSDC(uint256 amountUSDC) external;

    function buyYesWithUSDC(uint256 amountUSDC) external;

    function concludePrediction_3(bool winner) external returns (bool);

    function getPriceA() external view returns (uint256);

    function getPriceB() external view returns (uint256);

    function getPriceAInUSDC() external view returns (uint256);

    function getPriceBInUSDC() external view returns (uint256);
}
