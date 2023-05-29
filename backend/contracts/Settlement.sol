//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@api3/contracts/v0.8/interfaces/IProxy.sol";

interface ITrading {
    function settlePrediction(uint256, bool) external;

    function getPrediction(uint256) external view returns (Prediction memory);
}

struct Prediction {
    string tokenSymbol;
    int224 targetPricePoint;
    bool isAbove;
    address proxyAddress;
    uint256 fee;
    uint256 timestamp;
    uint256 deadline;
    bool isActive;
    address cpmm;
}

/// @dev The contract is inherently a data feed reader
contract PM_Settlement is Ownable {
    ITrading public tradingContract;

    constructor(address _trading) {
        tradingContract = ITrading(_trading);
    }

    // We can add an incentive to whoever calls it get some % of the original fee. This function is
    function evaluatePrediction(uint256 _predictionId) external {
        Prediction memory associatedPrediction = tradingContract.getPrediction(
            _predictionId
        );
        address associatedProxyAddress = associatedPrediction.proxyAddress;

        (int224 value, uint256 timestamp) = IProxy(associatedProxyAddress)
            .read();

        require(
            block.timestamp > associatedPrediction.deadline &&
                timestamp > associatedPrediction.deadline,
            "Can't run evaluation! Deadline not met."
        );

        //The price was predicted to be above the target point
        if (associatedPrediction.isAbove) {
            if (associatedPrediction.targetPricePoint > value)
                tradingContract.settlePrediction(_predictionId, true);
            else tradingContract.settlePrediction(_predictionId, false);
        } else {
            if (associatedPrediction.targetPricePoint < value)
                tradingContract.settlePrediction(_predictionId, true);
            else tradingContract.settlePrediction(_predictionId, false);
        }
    }
}
