//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@api3/contracts/v0.8/interfaces/IProxy.sol";

/// @dev Current order of settling a market :
/// Settlement : concludePrediction_1 -> Trading : conludePrediction_2 -> Each Unique MarketHandler : concludePrediction_3

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
    function concludePrediction_2(uint256, bool) external;

    function getNextPredictionId() external view returns (uint256);

    function getPrediction(uint256) external view returns (Prediction memory);
}

error PM_InvalidPredictionId();

/// @dev The contract is inherently a data feed reader
contract PM_Settlement is Ownable {
    /// @notice The Trading contract that acts as a middle ground for Settlement and MarketHandler
    ITrading public tradingContract;

    /// @param _trading The Trading Contract
    constructor(address _trading) {
        tradingContract = ITrading(_trading);
    }

    modifier isValidPredictionId(uint256 _id) {
        uint256 currentUpper = tradingContract.getNextPredictionId();
        if (_id >= currentUpper) revert PM_InvalidPredictionId();
        _;
    }

    /// @dev We can add an incentive to whoever calls it get some % of overall protocol fee for a given prediction.
    /// Note that this should come out > gas fee to run the txn in the first place. Or we use CRON job, EAC,
    /// Cloud-based scheduler.
    /// @dev Personally think that the 1st and 3rd options are good candidates.
    /// @param _predictionId The unique identifier for the prediction to be concluded.
    function concludePrediction_1(
        uint256 _predictionId
    ) external isValidPredictionId(_predictionId) {
        Prediction memory associatedPrediction = tradingContract.getPrediction(
            _predictionId
        );
        address associatedProxyAddress = associatedPrediction.proxyAddress;

        /// API3 FTW
        (int224 value, ) = IProxy(associatedProxyAddress).read();

        require(
            block.timestamp > associatedPrediction.deadline,
            "Can't run evaluation! Deadline not met."
        );

        /// @dev The price was predicted to be above the target point
        if (associatedPrediction.isAbove) {
            /// @dev And IS ABOVE the target and hence True
            if (associatedPrediction.targetPricePoint > value)
                tradingContract.concludePrediction_2(_predictionId, true);
                /// @dev NOT ABOVE hence False
            else tradingContract.concludePrediction_2(_predictionId, false);
        } else {
            if (associatedPrediction.targetPricePoint < value)
                tradingContract.concludePrediction_2(_predictionId, true);
            else tradingContract.concludePrediction_2(_predictionId, false);
        }
    }
}
