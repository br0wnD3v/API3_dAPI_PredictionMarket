// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/// @notice We need to track certain properties of the prediction to make sure it it concluded after the deadline only.
struct Prediction {
    string tokenSymbol;
    int224 targetPricePoint;
    bool isAbove;
    address proxyAddress;
    uint256 fee;
    uint256 timestamp;
    uint256 deadline;
    bool isActive;
    address marketHandler;
}

interface ITrading {
    function trackProgress(
        uint256 _id,
        address _caller,
        int256 _amountYes,
        int256 _amountNo
    ) external;

    function concludePrediction_2(uint256, bool) external;

    function getPrediction(uint256) external view returns (Prediction memory);
}
