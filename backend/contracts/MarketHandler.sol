// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IMarketHandler.sol";
import "./IERC20.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

error PM_IsClosedForTrading();
error PM_IsOpenForTrading();
error PM_InsufficientApprovedAmount();
error PM_TokenTransferFailed();
error PM_InsufficienTradeTokens();

contract PM_MarketHandler is Context, Ownable, IMarketHandler {
    using Counters for Counters.Counter;

    uint256 public reserveUSDC;
    uint256 public reserveYes;
    uint256 public reserveNo;

    uint256 public immutable I_SELF_ID;
    /// Base price of 10^18. 1 token of either = base price.
    uint256 public immutable I_BASE_PRICE;
    uint256 public immutable I_DEADLINE;
    uint256 public immutable I_DECIMALS;
    /// 1000000 = 100%, 0.1% = 1000.
    /// This is the total fee and this further divided between the creator and the platform.
    uint256 public immutable I_FEE;

    IERC20 usdcContract;

    address[] private yesHolders;
    Counters.Counter private yesIndex;
    mapping(address => uint256) private yesTokenAddressToIndex;
    mapping(address => uint256) private YesBalances;

    address[] private noHolders;
    Counters.Counter private noIndex;
    mapping(address => uint256) private noTokenAddressToIndex;
    mapping(address => uint256) private NoBalances;

    // Events
    event SwapOrder(address indexed trader, int256 amountYes, int256 amountNo);
    event BuyOrder(address indexed trader, uint256 amountYes, uint256 amountNo);

    modifier isOpen() {
        if (block.timestamp > I_DEADLINE) revert PM_IsClosedForTrading();
        _;
    }

    modifier isClosed() {
        if (block.timestamp <= I_DEADLINE) revert PM_IsOpenForTrading();
        _;
    }

    // 1000000 = 100%, 0.1% = 1000.
    constructor(
        uint256 _id,
        uint256 _fee,
        uint256 _deadline,
        uint256 _basePrice,
        address _usdcTokenAddress
    ) {
        I_SELF_ID = _id;
        I_BASE_PRICE = _basePrice;
        I_DEADLINE = _deadline;

        usdcContract = IERC20(_usdcTokenAddress);
        I_DECIMALS = 10 ** usdcContract.decimals();

        // _fee * 0.1% of the token regardless of the decimals value.
        I_FEE = (_fee * I_DECIMALS) / 10 ** 3;

        yesIndex.increment();
        noIndex.increment();
    }

    function swapTokenNoWithYes(uint256 _amountToSwap) external isOpen {
        if (NoBalances[_msgSender()] < _amountToSwap)
            revert PM_InsufficienTradeTokens();

        uint256 swapFee = getSwapFee();

        if (usdcContract.allowance(_msgSender(), address(this)) < swapFee)
            revert PM_InsufficientApprovedAmount();
        bool success = usdcContract.transferFrom(
            _msgSender(),
            address(this),
            swapFee
        );
        if (!success) revert PM_TokenTransferFailed();

        NoBalances[_msgSender()] -= _amountToSwap;
        reserveNo -= _amountToSwap;
        YesBalances[_msgSender()] += _amountToSwap;
        reserveYes += _amountToSwap;

        int256 amount = int256(_amountToSwap);
        emit SwapOrder(_msgSender(), amount, -1 * amount);
    }

    function swapTokenYesWithNo(uint256 _amountToSwap) external isOpen {
        if (YesBalances[_msgSender()] < _amountToSwap)
            revert PM_InsufficienTradeTokens();

        uint256 swapFee = getSwapFee();

        if (usdcContract.allowance(_msgSender(), address(this)) < swapFee)
            revert PM_InsufficientApprovedAmount();
        bool success = usdcContract.transferFrom(
            _msgSender(),
            address(this),
            swapFee
        );
        if (!success) revert PM_TokenTransferFailed();

        NoBalances[_msgSender()] += _amountToSwap;
        reserveNo += _amountToSwap;
        YesBalances[_msgSender()] -= _amountToSwap;
        reserveYes -= _amountToSwap;

        int256 amount = int256(_amountToSwap);
        emit SwapOrder(_msgSender(), -1 * amount, amount);
    }

    function buyNoToken(uint256 _amount) external isOpen {
        if (usdcContract.allowance(_msgSender(), address(this)) < _amount)
            revert PM_InsufficientApprovedAmount();
        bool success = usdcContract.transferFrom(
            _msgSender(),
            address(this),
            _amount
        );
        if (!success) revert PM_TokenTransferFailed();

        reserveNo += _amount;
        NoBalances[_msgSender()] += _amount;

        if (noTokenAddressToIndex[_msgSender()] == 0) {
            uint256 index = noIndex.current();

            noTokenAddressToIndex[_msgSender()] = index;
            noHolders[index] = _msgSender();

            noIndex.increment();
        }

        emit BuyOrder(_msgSender(), 0, _amount);
    }

    function buyYesToken(uint256 _amount) external isOpen {
        if (usdcContract.allowance(_msgSender(), address(this)) < _amount)
            revert PM_InsufficientApprovedAmount();
        bool success = usdcContract.transferFrom(
            _msgSender(),
            address(this),
            _amount
        );
        if (!success) revert PM_TokenTransferFailed();

        reserveYes += _amount;
        YesBalances[_msgSender()] += _amount;

        if (yesTokenAddressToIndex[_msgSender()] == 0) {
            uint256 index = yesIndex.current();

            yesTokenAddressToIndex[_msgSender()] = index;
            yesHolders[index] = _msgSender();

            yesIndex.increment();
        }

        emit BuyOrder(_msgSender(), _amount, 0);
    }

    // 10% of the set trade fee.
    function getSwapFee() public view returns (uint256) {
        return I_FEE / 10;
    }

    function getYesTokenCount() external view returns (uint256) {
        return reserveYes;
    }

    function getNoTokenCount() external view returns (uint256) {
        return reserveNo;
    }

    /// @notice The trading contract call this function for each individual prediction.
    function concludePrediction_3(bool vote) external isClosed returns (bool) {}

    receive() external payable {}

    fallback() external payable {}
}
