// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IMarketHandler.sol";
import "./IERC20.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error PM_IsClosedForTrading();
error PM_IsOpenForTrading();
error PM_InsufficientApprovedAmount();
error PM_TokenTransferFailed();

contract PM_MarketHandler is Context, Ownable, IMarketHandler {
    uint256 public reserveUSDC;
    uint256 public reserveYes;
    uint256 public reserveNo;

    uint256 public immutable I_SELF_ID;
    /// Base price of 10^18. 1 token of either = base price.
    uint256 public immutable I_BASE_PRICE;
    uint256 public immutable I_DEADLINE;
    uint256 public immutable I_DECIMALS;

    // 1000000 = 100%, 0.1% = 1000.
    //This is the total fee and this further divided between the creator and the platform.
    uint256 public immutable I_FEE;

    IERC20 usdcContract;

    mapping(address => uint256) private YesBalances;
    mapping(address => uint256) private NoBalances;

    // Events
    event SwapOrder(
        address indexed trader,
        int256 indexed amountYes,
        int256 indexed amountNo
    );
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
        uint256 _basePrice,
        uint256 _deadline,
        uint256 _fee,
        address _usdcTokenAddress
    ) {
        I_SELF_ID = _id;
        I_BASE_PRICE = _basePrice;
        I_DEADLINE = _deadline;
        I_FEE = _fee * 10 ** 3;
        usdcContract = IERC20(_usdcTokenAddress);
        I_DECIMALS = 10 ** usdcContract.decimals();
    }

    function getSwapFee() public view returns (uint256) {
        return I_FEE / 10;
    }

    function swapTokenNoWithYes(uint256 _amountToSwap) external {
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
        YesBalances[_msgSender()] += _amountToSwap;

        int256 amount = int256(_amountToSwap);
        emit SwapOrder(_msgSender(), amount, -1 * amount);
    }

    function swapTokenYesWithNo(uint256 _amountToSwap) external {
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
        YesBalances[_msgSender()] -= _amountToSwap;

        int256 amount = int256(_amountToSwap);
        emit SwapOrder(_msgSender(), -1 * amount, amount);
    }

    function buyNoToken(uint256 _amount) external {
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

        emit BuyOrder(_msgSender(), _amount, 0);
    }

    function buyYesToken(uint256 _amount) external {
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

        emit BuyOrder(_msgSender(), 0, _amount);
    }

    /// @notice The trading contract call this function for each individual prediction.
    function concludePrediction_3(bool vote) external isClosed returns (bool) {
        //Settlements
    }

    receive() external payable {}

    fallback() external payable {}
}
