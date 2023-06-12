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
error PM_InvalidAmountSet();
error PM_RewardsNotAvailable();
error PM_RewardAlreadyCollected();
error PM_UserDidNotWin();

contract PM_MarketHandler is Context, Ownable, IMarketHandler {
    using Counters for Counters.Counter;

    // ReserveUSDC = reserveYes + reserveNo
    uint256 public reserveUSDC;
    uint256 public reserveFEE;
    uint256 public reserveYes;
    uint256 public reserveNo;

    bool public RewardsClaimable;
    bool public winner;

    uint256 public immutable I_SELF_ID;
    /// Base price of 10^18. 1 token of either = base price.
    uint256 public immutable I_BASE_PRICE;
    uint256 public immutable I_DEADLINE;
    uint256 public immutable I_DECIMALS;
    /// 1000000 = 100%, 0.1% = 1000.
    /// This is the total fee and this further divided between the creator and the platform.
    uint256 public immutable I_FEE;

    IERC20 public immutable I_USDC_CONTRACT;
    address private immutable I_VAULT_ADDRESS;

    Counters.Counter private yesIndex;
    address[] private yesHolders;
    mapping(address => uint256) private yesTokenAddressToIndex;
    mapping(address => uint256) private YesBalances;

    Counters.Counter private noIndex;
    address[] private noHolders;
    mapping(address => uint256) private noTokenAddressToIndex;
    mapping(address => uint256) private NoBalances;

    mapping(address => bool) private rewardCollected;

    // Events
    event SwapOrder(address indexed trader, int256 amountYes, int256 amountNo);
    event BuyOrder(address indexed trader, uint256 amountYes, uint256 amountNo);
    event SellOrder(
        address indexed trader,
        uint256 amountYes,
        uint256 amountNo
    );
    event WinnerDeclared(bool winner);
    event RewardCollected(address indexed user, uint256 amountWon);

    modifier isClaimable() {
        if (!RewardsClaimable) revert PM_RewardsNotAvailable();
        _;
    }

    modifier isOpen() {
        if (block.timestamp > I_DEADLINE) revert PM_IsClosedForTrading();
        _;
    }

    modifier isClosed() {
        if (block.timestamp <= I_DEADLINE) revert PM_IsOpenForTrading();
        _;
    }

    // _fee * 0.1% of the tokens regardless of the decimals value. Should be a natural number N.
    constructor(
        uint256 _id,
        uint256 _fee,
        uint256 _deadline,
        uint256 _basePrice,
        address _usdcTokenAddress,
        address _vaultAddress
    ) {
        I_SELF_ID = _id;
        I_BASE_PRICE = _basePrice;
        I_DEADLINE = _deadline;
        I_VAULT_ADDRESS = _vaultAddress;
        IERC20 usdcContract = IERC20(_usdcTokenAddress);
        I_USDC_CONTRACT = usdcContract;
        I_DECIMALS = 10 ** usdcContract.decimals();
        I_FEE = (_fee * 10 ** usdcContract.decimals()) / 10 ** 3;

        yesIndex.increment();
        noIndex.increment();
    }

    /// @dev ALL THE AMOUNTS MENTIONED AS PARAM SHOULD BE IN A FORM OF x * 10**I_DECIMALS.
    function swapTokenNoWithYes(
        uint256 _amountToSwap
    ) external override isOpen {
        if (NoBalances[_msgSender()] < _amountToSwap)
            revert PM_InsufficienTradeTokens();

        uint256 swapFee = getFee(_amountToSwap);

        NoBalances[_msgSender()] -= _amountToSwap;
        reserveNo -= _amountToSwap;
        YesBalances[_msgSender()] += _amountToSwap - swapFee;
        reserveYes += _amountToSwap;

        int256 amountYes = int256(_amountToSwap - swapFee);
        int256 amountNo = int256(_amountToSwap);

        I_USDC_CONTRACT.transfer(I_VAULT_ADDRESS, swapFee);
        reserveFEE += swapFee;

        emit SwapOrder(_msgSender(), amountYes, -1 * amountNo);
    }

    function swapTokenYesWithNo(
        uint256 _amountToSwap
    ) external override isOpen {
        if (YesBalances[_msgSender()] < _amountToSwap)
            revert PM_InsufficienTradeTokens();

        uint256 swapFee = getFee(_amountToSwap);

        NoBalances[_msgSender()] += _amountToSwap - swapFee;
        reserveNo += _amountToSwap;
        YesBalances[_msgSender()] -= _amountToSwap;
        reserveYes -= _amountToSwap;

        int256 amountYes = int256(_amountToSwap);
        int256 amountNo = int256(_amountToSwap - swapFee);

        I_USDC_CONTRACT.transfer(I_VAULT_ADDRESS, swapFee);
        reserveFEE += swapFee;

        emit SwapOrder(_msgSender(), -1 * amountYes, amountNo);
    }

    function buyNoToken(uint256 _amount) external override isOpen {
        if (I_USDC_CONTRACT.allowance(_msgSender(), address(this)) < _amount)
            revert PM_InsufficientApprovedAmount();
        bool success = I_USDC_CONTRACT.transferFrom(
            _msgSender(),
            address(this),
            _amount
        );
        if (!success) revert PM_TokenTransferFailed();

        uint256 fee = getFee(_amount);
        I_USDC_CONTRACT.transfer(I_VAULT_ADDRESS, fee);

        reserveFEE += fee;
        reserveUSDC += _amount - fee;
        reserveNo += _amount - fee;

        uint256 finalAmount = _amount - fee;
        NoBalances[_msgSender()] += finalAmount;

        if (noTokenAddressToIndex[_msgSender()] == 0) {
            uint256 index = noIndex.current();

            noTokenAddressToIndex[_msgSender()] = index;
            noHolders[index] = _msgSender();

            noIndex.increment();
        }

        emit BuyOrder(_msgSender(), 0, finalAmount);
    }

    function buyYesToken(uint256 _amount) external override isOpen {
        if (I_USDC_CONTRACT.allowance(_msgSender(), address(this)) < _amount)
            revert PM_InsufficientApprovedAmount();
        bool success = I_USDC_CONTRACT.transferFrom(
            _msgSender(),
            address(this),
            _amount
        );
        if (!success) revert PM_TokenTransferFailed();

        uint256 fee = getFee(_amount);
        I_USDC_CONTRACT.transfer(I_VAULT_ADDRESS, fee);

        reserveFEE += fee;
        reserveUSDC += _amount - fee;
        reserveYes += _amount - fee;

        uint256 finalAmount = _amount - fee;
        YesBalances[_msgSender()] += finalAmount;

        if (yesTokenAddressToIndex[_msgSender()] == 0) {
            uint256 index = yesIndex.current();

            yesTokenAddressToIndex[_msgSender()] = index;
            yesHolders[index] = _msgSender();

            yesIndex.increment();
        }

        emit BuyOrder(_msgSender(), _amount, 0);
    }

    function sellNoToken(uint256 _amount) external override isOpen {
        if (NoBalances[_msgSender()] < _amount) revert PM_InvalidAmountSet();

        uint256 fee = getFee(_amount);
        I_USDC_CONTRACT.transfer(I_VAULT_ADDRESS, fee);
        reserveFEE += fee;

        uint256 toSend = _amount - fee;
        NoBalances[_msgSender()] -= _amount;

        if (NoBalances[_msgSender()] == 0) {
            uint256 index = noTokenAddressToIndex[_msgSender()];

            noHolders[index] = address(0);
            noTokenAddressToIndex[_msgSender()] = 0;
        }

        bool success = I_USDC_CONTRACT.transfer(_msgSender(), toSend);
        if (!success) revert PM_TokenTransferFailed();

        reserveUSDC -= _amount;

        emit SellOrder(_msgSender(), 0, toSend);
    }

    function sellYesToken(uint256 _amount) external override isOpen {
        if (YesBalances[_msgSender()] < _amount) revert PM_InvalidAmountSet();

        uint256 fee = getFee(_amount);
        I_USDC_CONTRACT.transfer(I_VAULT_ADDRESS, fee);
        reserveFEE += fee;

        uint256 toSend = _amount - fee;
        YesBalances[_msgSender()] -= _amount;

        if (YesBalances[_msgSender()] == 0) {
            uint256 index = yesTokenAddressToIndex[_msgSender()];

            yesHolders[index] = address(0);
            yesTokenAddressToIndex[_msgSender()] = 0;
        }

        bool success = I_USDC_CONTRACT.transfer(_msgSender(), toSend);
        if (!success) revert PM_TokenTransferFailed();

        reserveUSDC -= _amount;

        emit SellOrder(_msgSender(), toSend, 0);
    }

    /// @notice The trading contract call this function for each individual prediction.
    /// Owner beign the trading contract.
    /// vote - True => Yes won
    /// vote - False => No won
    function concludePrediction_3(
        bool vote
    ) external override isClosed onlyOwner {
        winner = vote;
        emit WinnerDeclared(vote);

        RewardsClaimable = true;
    }

    function collectRewards() external isClaimable {
        if (rewardCollected[_msgSender()]) revert PM_RewardAlreadyCollected();

        if (winner == true) {
            if (YesBalances[_msgSender()] == 0) revert PM_UserDidNotWin();
        } else {
            if (NoBalances[_msgSender()] == 0) revert PM_UserDidNotWin();
        }

        uint256 totalPool = reserveUSDC;
        uint256 userTokenCount = YesBalances[_msgSender()];
        uint256 userShare = (userTokenCount * I_DECIMALS) / totalPool;

        YesBalances[_msgSender()] = 0;
        rewardCollected[_msgSender()] = true;

        I_USDC_CONTRACT.transfer(_msgSender(), userShare);

        emit RewardCollected(_msgSender(), userShare);
    }

    /// GETTER FUNCTIONS ==========================================

    function getFee(uint256 _amount) public view returns (uint256) {
        return (_amount * I_FEE) / I_DECIMALS;
    }

    function getNoReserve() external view returns (uint256) {
        return reserveNo;
    }

    function getYesReserve() external view returns (uint256) {
        return reserveYes;
    }

    function getYesTokenCount(address _add) external view returns (uint256) {
        return YesBalances[_add];
    }

    function getNoTokenCount(address _add) external view returns (uint256) {
        return NoBalances[_add];
    }

    receive() external payable {}

    fallback() external payable {}
}
