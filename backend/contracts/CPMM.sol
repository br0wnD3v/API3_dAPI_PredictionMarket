// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICPMM.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error PM_IsClosedForTrading();
error PM_IsOpenForTrading();
error PM_NotReadyForTrades();

contract PM_CPMM is Context, Ownable, ICPMM {
    uint256 public reserveNo;
    uint256 public reserveYes;
    uint256 public deadline;
    uint256 public fee;

    uint256 public CONSTANT_K;
    uint256 private immutable SELF_ID;
    uint256 private constant DECIMALS = 18;

    bool private ready;

    IERC20 usdcToken;

    mapping(address => uint256) private YesBalances;
    mapping(address => uint256) private NoBalances;

    // Events
    event SwapOrder(
        address indexed trader,
        uint256 amountYes,
        uint256 amountNo
    );
    event BuyOrder(address indexed trader, uint256 amountYes, uint256 amountNo);

    modifier isOpen() {
        if (block.timestamp > deadline) revert PM_IsClosedForTrading();
        _;
    }

    modifier isClosed() {
        if (block.timestamp <= deadline) revert PM_IsOpenForTrading();
        _;
    }

    modifier isReady() {
        if (!ready) revert PM_NotReadyForTrades();
        _;
    }

    // Constructor
    constructor(uint256 _id, uint256 _fee, address _usdcTokenAddress) {
        SELF_ID = _id;
        fee = _fee;
        usdcToken = IERC20(_usdcTokenAddress);
    }

    function enableForTrades(
        uint256 _initialSupply,
        uint256 _deadline
    ) external onlyOwner {
        reserveNo = _initialSupply * 10 ** DECIMALS;
        reserveYes = _initialSupply * 10 ** DECIMALS;
        deadline = _deadline;
        ready = true;
    }

    // External function to SwapOrder tokenNo for tokenYes
    function swapNoForYes(uint256 amountA) external isOpen {
        require(amountA > 0, "Amount must be greater than zero");

        // Calculate the amount of tokenYes to be received
        uint256 amountB = (reserveYes * amountA) / reserveNo;

        reserveNo += amountA;
        reserveYes -= amountB;

        NoBalances[_msgSender()] += amountA;
        YesBalances[_msgSender()] -= amountA;

        if (reserveNo * reserveYes != CONSTANT_K) revert();

        emit SwapOrder(msg.sender, amountA, amountB);
    }

    // External function to SwapOrder tokenYes for tokenNo
    function swapYesForNo(uint256 amountB) external isOpen {
        require(amountB > 0, "Amount must be greater than zero");

        // Calculate the amount of tokenNo to be received
        uint256 amountA = (reserveNo * amountB) / reserveYes;

        reserveNo -= amountA;
        reserveYes += amountB;

        NoBalances[_msgSender()] -= amountA;
        YesBalances[_msgSender()] += amountA;

        if (reserveNo * reserveYes != CONSTANT_K) revert();

        // Emit SwapOrder event
        emit SwapOrder(msg.sender, amountA, amountB);
    }

    function buyNoWithUSDC(uint256 amountUSDC) external isOpen {
        require(amountUSDC > 0, "Amount must be greater than zero");

        // Transfer USDC tokens from the user to the contract
        require(
            usdcToken.transferFrom(msg.sender, address(this), amountUSDC),
            "Failed to transfer USDC tokens"
        );

        // Calculate the amount of No tokens to be received
        uint256 amountNo = (amountUSDC * reserveNo) / (reserveYes);

        reserveNo += amountNo;
        reserveYes -= amountUSDC;

        NoBalances[_msgSender()] += amountUSDC;
        YesBalances[_msgSender()] -= amountUSDC;

        if (reserveNo * reserveYes != CONSTANT_K) revert();

        // Emit SwapOrder event
        emit SwapOrder(msg.sender, amountUSDC, amountNo);
    }

    function buyYesWithUSDC(uint256 amountUSDC) external isOpen {
        require(amountUSDC > 0, "Amount must be greater than zero");

        // Transfer USDC tokens from the user to the contract
        require(
            usdcToken.transferFrom(msg.sender, address(this), amountUSDC),
            "Failed to transfer USDC tokens"
        );

        // Calculate the amount of Yes tokens to be received
        uint256 amountYes = (amountUSDC * reserveYes) / (reserveNo);

        reserveYes += amountYes;
        reserveNo -= amountUSDC;

        NoBalances[_msgSender()] -= amountUSDC;
        YesBalances[_msgSender()] += amountUSDC;

        if (reserveNo * reserveYes != CONSTANT_K) revert();

        // Emit SwapOrder event
        emit SwapOrder(msg.sender, amountUSDC, amountYes);
    }

    /// @notice THIS IS WHERE DAPIS WILL BE CALLED TO BALANCE THINGS OUT
    function conclude(bool vote) external isClosed returns (bool) {
        //Settlements
    }

    // External view function to get the current price of tokenNo in terms of tokenYes
    function getPriceA() external view returns (uint256) {
        return reserveYes / reserveNo;
    }

    // External view function to get the current price of tokenYes in terms of tokenNo
    function getPriceB() external view returns (uint256) {
        return reserveNo / reserveYes;
    }

    // External view function to get the current price of tokenNo in terms of USDC
    function getPriceAInUSDC() external view returns (uint256) {
        return (reserveYes) / reserveNo;
    }

    // External view function to get the current price of tokenYes in terms of USDC
    function getPriceBInUSDC() external view returns (uint256) {
        return (reserveNo) / reserveYes;
    }

    receive() external payable {}

    fallback() external payable {}
}
