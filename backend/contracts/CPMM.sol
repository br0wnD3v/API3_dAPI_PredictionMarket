// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error PM_ClosedForTrading();
error PM_OpenForTrading();

contract ConstantProductAMM is Context, Ownable {
    uint256 public reserveAgainst;
    uint256 public reserveFavour;
    uint256 public immutable PREDICTION_BASE_PRICE;
    uint256 public immutable CONSTANT_K;

    IERC20 usdcToken;

    uint256 deadline;

    mapping(address => uint256) private favourBalances;
    mapping(address => uint256) private againstBalances;

    // Events
    event Swap(address indexed trader, uint256 amountIn, uint256 amountOut);

    modifier isOpen() {
        if (block.timestamp > deadline) revert PM_ClosedForTrading();
        _;
    }

    modifier isClosed() {
        if (block.timestamp < deadline) revert PM_OpenForTrading();
        _;
    }

    // Constructor
    constructor(
        uint256 _initialSupply,
        uint256 _basePrice,
        uint256 _deadline,
        address _usdcTokenAddress
    ) {
        reserveAgainst = _initialSupply;
        reserveFavour = _initialSupply;
        PREDICTION_BASE_PRICE = _basePrice;
        CONSTANT_K = _initialSupply * _initialSupply;
        deadline = _deadline;
        usdcToken = IERC20(_usdcTokenAddress);
    }

    // External function to add liquidity
    function addLiquidity(
        uint256 amountA,
        uint256 amountB
    ) external isOpen onlyOwner {
        require(
            amountA > 0 && amountB > 0,
            "Amounts must be greater than zero"
        );

        // Update reserves
        reserveAgainst += amountA;
        reserveFavour += amountB;

        favourBalances[_msgSender()] += amountB;
        againstBalances[_msgSender()] += amountB;
    }

    // External function to swap tokenAgainst for tokenFavour
    function swapAgainstForFavour(uint256 amountA) external isOpen {
        require(amountA > 0, "Amount must be greater than zero");

        // Calculate the amount of tokenFavour to be received
        uint256 amountB = (reserveFavour * amountA) / reserveAgainst;

        reserveAgainst += amountA;
        reserveFavour -= amountB;

        if (reserveAgainst * reserveFavour != CONSTANT_K) revert();

        emit Swap(msg.sender, amountA, amountB);
    }

    // External function to swap tokenFavour for tokenAgainst
    function swapFavourForAgainst(uint256 amountB) external isOpen {
        require(amountB > 0, "Amount must be greater than zero");

        // Calculate the amount of tokenAgainst to be received
        uint256 amountA = (reserveAgainst * amountB) / reserveFavour;

        reserveAgainst -= amountA;
        reserveFavour += amountB;

        if (reserveAgainst * reserveFavour != CONSTANT_K) revert();

        // Emit swap event
        emit Swap(msg.sender, amountA, amountB);
    }

    function buyAgainstWithUSDC(uint256 amountUSDC) external isOpen {
        require(amountUSDC > 0, "Amount must be greater than zero");

        // Transfer USDC tokens from the user to the contract
        require(
            usdcToken.transferFrom(msg.sender, address(this), amountUSDC),
            "Failed to transfer USDC tokens"
        );

        // Calculate the amount of Against tokens to be received
        uint256 amountAgainst = (amountUSDC * reserveAgainst) /
            (reserveFavour * PREDICTION_BASE_PRICE);

        reserveAgainst += amountAgainst;
        reserveFavour -= amountUSDC;

        if (reserveAgainst * reserveFavour != CONSTANT_K) revert();

        // Emit swap event
        emit Swap(msg.sender, amountUSDC, amountAgainst);
    }

    function buyFavourWithUSDC(uint256 amountUSDC) external isOpen {
        require(amountUSDC > 0, "Amount must be greater than zero");

        // Transfer USDC tokens from the user to the contract
        require(
            usdcToken.transferFrom(msg.sender, address(this), amountUSDC),
            "Failed to transfer USDC tokens"
        );

        // Calculate the amount of Favour tokens to be received
        uint256 amountFavour = (amountUSDC * reserveFavour) /
            (reserveAgainst * PREDICTION_BASE_PRICE);

        reserveFavour += amountFavour;
        reserveAgainst -= amountUSDC;

        if (reserveAgainst * reserveFavour != CONSTANT_K) revert();

        // Emit swap event
        emit Swap(msg.sender, amountUSDC, amountFavour);
    }

    /// @notice THIS IS WHERE DAPIS WILL BE CALLED TO BALANCE THINGS OUT
    function concludePrediction() external isClosed {}

    // External view function to get the current price of tokenAgainst in terms of tokenFavour
    function getPriceA() external view returns (uint256) {
        return reserveFavour / reserveAgainst;
    }

    // External view function to get the current price of tokenFavour in terms of tokenAgainst
    function getPriceB() external view returns (uint256) {
        return reserveAgainst / reserveFavour;
    }

    // External view function to get the current price of tokenAgainst in terms of USDC
    function getPriceAInUSDC() external view returns (uint256) {
        return (reserveFavour * PREDICTION_BASE_PRICE) / reserveAgainst;
    }

    // External view function to get the current price of tokenFavour in terms of USDC
    function getPriceBInUSDC() external view returns (uint256) {
        return (reserveAgainst * PREDICTION_BASE_PRICE) / reserveFavour;
    }

    receive() external payable {}

    fallback() external payable {}
}
