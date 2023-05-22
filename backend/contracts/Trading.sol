// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CPMM.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

struct Prediction {
    string description; // Prediction description
    uint256 supply; // Total supply of prediction tokens
    uint256 timestamp; // Timestamp of prediction creation
    address cpmm; // The contract responsible for prediction functionality
    bool isActive; // Check if the prediction is open or closed
}

contract PredictionMarket is Context, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private nextPredictionId;

    mapping(uint256 => Prediction) private predictions;

    address usdcAddress;

    constructor(address _usdc) {
        usdcAddress = _usdc;
        nextPredictionId.increment();
    }

    function createPrediction(
        string memory _description,
        uint256 _initialSupply,
        uint256 _basePrice,
        uint256 _deadline
    ) external onlyOwner returns (uint256) {
        uint256 predictionId = nextPredictionId.current();

        Prediction storage prediction = predictions[predictionId];
        require(
            !prediction.isActive && prediction.supply > 0,
            "Prediction already exists."
        );

        ConstantProductAMM predictionCPMM = new ConstantProductAMM(
            _initialSupply,
            _basePrice,
            _deadline,
            usdcAddress
        );

        Prediction memory toAdd = Prediction({
            description: _description,
            supply: _initialSupply,
            timestamp: block.timestamp,
            cpmm: address(predictionCPMM),
            isActive: true
        });

        predictions[predictionId] = toAdd;

        nextPredictionId.increment();

        return predictionId;
    }

    function enterPrediction(uint256 _predictionId) external {}

    function closePrediction(uint256 _predicitonId) external {}

    receive() external payable {}

    fallback() external payable {}
}
