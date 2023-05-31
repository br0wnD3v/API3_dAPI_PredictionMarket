// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CPMM.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Prediction {
    string tokenSymbol; // The token symbol in question
    int224 targetPricePoint; // The target price point
    bool isAbove; // This boolean is responsible for defining if the prediction is below or above the price point
    address proxyAddress; // Address of the relevant proxy contract for each asset.
    uint256 fee; // 1 = 0.01%, 100 = 1%, Creator's cut which is further divided as a 20:80 ratio where 20% goes to the protcol and remaining is held by the prediction creator.
    uint256 timestamp; // Timestamp of the creation of prediction
    uint256 deadline; // Timestamp when the prediction is to end
    bool isActive; // Check if the prediction is open or closed
    address cpmm; // The contract responsible for prediction functionality
}

error PM_InsufficientApprovedAmount();
error PM_Conclude_FUCKED_UP();

contract PredictionMarket is Context, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private nextPredictionId;

    uint256 TARGET_DECIMALS = 18;

    mapping(uint256 => Prediction) private predictions;
    mapping(uint256 => address) private predictionIdToProxy;

    event PredictionCreated(
        uint256 indexed predictionId,
        address indexed creator,
        uint256 timestamp
    );
    event ConcludeFatalError(
        uint256 indexed predictionId,
        uint256 timestamp,
        int224 priceReading,
        int224 priceTarget
    );

    IERC20 usdcContract;
    address public settlementAddress;

    modifier callerIsSettlement(address _caller) {
        require(_caller == settlementAddress);
        _;
    }

    constructor(address _usdc) {
        usdcContract = IERC20(_usdc);
        nextPredictionId.increment();
    }

    function createPrediction(
        string memory _tokenSymbol,
        address _proxyAddress,
        bool _isAbove,
        int224 _targetPricePoint,
        uint256 _initialSupply,
        uint256 _liquidity,
        uint256 _fee,
        uint256 _deadline,
        address _caller
    ) external onlyOwner returns (uint256) {
        require(
            usdcContract.allowance(_caller, address(this)) >= _liquidity,
            "Allowance not set!"
        );
        require(
            _proxyAddress != address(0),
            "Can't have address zero as the proxy's address."
        );

        uint256 predictionId = nextPredictionId.current();
        Prediction storage prediction = predictions[predictionId];

        require(prediction.timestamp != 0, "Prediction already exists.");

        bool success = usdcContract.transferFrom(
            _caller,
            address(this),
            _liquidity
        );
        if (!success) revert PM_InsufficientApprovedAmount();

        PM_CPMM predictionCPMM = new PM_CPMM(
            predictionId,
            _fee,
            address(usdcContract)
        );

        Prediction memory toAdd = Prediction({
            tokenSymbol: _tokenSymbol,
            targetPricePoint: _targetPricePoint,
            isAbove: _isAbove,
            proxyAddress: _proxyAddress,
            fee: _fee,
            timestamp: block.timestamp,
            deadline: _deadline,
            cpmm: address(predictionCPMM),
            isActive: true
        });
        predictions[predictionId] = toAdd;
        predictionIdToProxy[predictionId] = _proxyAddress;

        predictionCPMM.enableForTrades(_initialSupply, _deadline);

        nextPredictionId.increment();

        emit PredictionCreated(predictionId, _caller, block.timestamp);
        return predictionId;
    }

    /// @dev
    // vote - True : The people who voted for 'Yes' for a given prediction.
    // vote - False : The people who voted for 'No' for a given prediction.

    // Functions for the traders
    function enterPrediction(uint256 _predictionId, bool vote) external {}

    function swapPrediction(uint256 _predictionId, bool vote) external {}

    function leavePrediction(uint256 _predictiunId, bool vote) external {}

    /// @notice Called by the Settlement contract which concludes the prediction and returns the vote i.e if the
    /// prediction was in the favour of 'Yes' or 'No'.
    function concludePrediction_2(
        uint256 _predictionId,
        bool vote
    ) external callerIsSettlement(_msgSender()) {
        require(predictions[_predictionId].deadline > block.timestamp);

        address associatedCPMMAddress = predictions[_predictionId].cpmm;
        ICPMM cpmmInstance = ICPMM(associatedCPMMAddress);

        bool success = cpmmInstance.concludePrediction_3(vote);
        if (!success) revert PM_Conclude_FUCKED_UP();
    }

    /// @notice Setter function
    function setSettlementContract(address _settlement) external onlyOwner {
        settlementAddress = _settlement;
    }

    /// @notice Getter functions
    function getPrediction(
        uint256 _predictionId
    ) external view returns (Prediction memory) {
        return predictions[_predictionId];
    }

    function getProxyAddressForPrediction(
        uint256 _predictionId
    ) external view returns (address) {
        return predictionIdToProxy[_predictionId];
    }

    receive() external payable {}

    fallback() external payable {}
}
