// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICPMM.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error PM_IsClosedForTrading();
error PM_IsOpenForTrading();
error PM_NotReadyForTrades();
error PM_ConstantKViolated();

contract PM_CPMM is Context, Ownable, ICPMM {
    uint256 public reserveNo;
    uint256 public reserveYes;
    uint256 public reserveUSDC;
    uint256 public deadline;
    uint256 public feePercentage;

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

    constructor(uint256 _id, uint256 _fee, address _usdcTokenAddress) {
        SELF_ID = _id;
        feePercentage = _fee;
        usdcToken = IERC20(_usdcTokenAddress);
    }

    /// @dev The main function that initiates the prediction.
    function enableForTrades(
        uint256 _initialSupply,
        uint256 _deadline
    ) external onlyOwner {
        reserveNo = _initialSupply * 10 ** DECIMALS;
        reserveYes = _initialSupply * 10 ** DECIMALS;
        deadline = _deadline;
        ready = true;
    }

    /// @notice The trading contract call this function for each individual prediction.
    function concludePrediction_3(
        bool vote
    ) external isClosed isReady returns (bool) {
        //Settlements
    }

    function buyYesToken(
        uint256 amountIn,
        address caller
    ) external isOpen isReady {
        require(amountIn > 0, "Invalid amount");

        uint256 amountOut;
        uint256 newYesReserve = reserveYes;
        uint256 newNoReserve = reserveNo;

        amountOut = calculateAmountOut(reserveYes, reserveNo, amountIn);
        newYesReserve += amountIn;
        newNoReserve -= amountOut;

        require(amountOut > 0, "Insufficient liquidity");

        YesBalances[caller] += (amountOut - amountIn);

        uint256 usdcToTransfer = (amountIn * reserveUSDC) /
            (reserveYes + reserveNo);
        uint256 fee = (usdcToTransfer * feePercentage) / 1000; // Calculate fee (0.5%)

        usdcToken.transferFrom(caller, address(this), usdcToTransfer + fee);

        reserveUSDC += usdcToTransfer + fee;
        reserveYes = newYesReserve;
        reserveNo = newNoReserve;

        if (reserveNo * reserveYes != CONSTANT_K) revert PM_ConstantKViolated();

        emit BuyOrder(caller, amountIn, amountOut);
    }

    function buyNoToken(
        uint256 amountIn,
        address caller
    ) external isOpen isReady {
        require(amountIn > 0, "Invalid amount");

        uint256 amountOut;
        uint256 newNoReserve = reserveNo;
        uint256 newYesReserve = reserveYes;

        amountOut = calculateAmountOut(reserveNo, reserveYes, amountIn);
        newNoReserve += amountIn;
        newYesReserve -= amountOut;

        require(amountOut > 0, "Insufficient liquidity");

        NoBalances[caller] += (amountOut - amountIn);

        uint256 usdcToTransfer = (amountIn * reserveUSDC) /
            (reserveYes + reserveNo);
        uint256 fee = (usdcToTransfer * feePercentage) / 1000; // Calculate fee (0.5%)

        usdcToken.transferFrom(caller, address(this), usdcToTransfer + fee);

        reserveUSDC += usdcToTransfer + fee;
        reserveYes = newYesReserve;
        reserveNo = newNoReserve;

        if (reserveNo * reserveYes != CONSTANT_K) revert PM_ConstantKViolated();

        emit BuyOrder(caller, amountIn, amountOut);
    }

    function getUSDCToPayEstimate(
        uint256 amountIn
    ) external view returns (uint256) {
        return (amountIn * reserveUSDC) / (reserveYes + reserveNo);
    }

    function swapTokens(uint amountIn, bool isYesToNo) external {
        require(amountIn > 0, "Amount must be greater than zero");

        if (isYesToNo) {
            uint amountOut = getAmountOut(amountIn, reserveYes, reserveNo);
            require(amountOut > 0, "Insufficient liquidity");
            require(
                NoBalances[msg.sender] >= amountOut,
                "Insufficient No balance"
            );

            YesBalances[msg.sender] += amountIn;
            NoBalances[msg.sender] -= amountOut;
            reserveYes += amountIn;
            reserveNo -= amountOut;
        } else {
            uint amountOut = getAmountOut(amountIn, reserveNo, reserveYes);
            require(amountOut > 0, "Insufficient liquidity");
            require(
                YesBalances[msg.sender] >= amountOut,
                "Insufficient Yes balance"
            );

            NoBalances[msg.sender] += amountIn;
            YesBalances[msg.sender] -= amountOut;
            reserveNo += amountIn;
            reserveYes -= amountOut;
        }
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint) {
        require(amountIn > 0, "Amount must be greater than zero");
        require(
            reserveIn > 0 && reserveOut > 0,
            "Reserves must be greater than zero"
        );

        uint amountInWithFee = amountIn * 997; // Apply 0.3% fee (0.997)
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        return numerator / denominator;
    }

    function calculateAmountOut(
        uint256 x,
        uint256 y,
        uint256 amountIn
    ) internal view returns (uint256) {
        return y - (CONSTANT_K / (x + amountIn));
    }

    // function buyYesWithUSDC(
    //     uint256 amountUSDC,
    //     address caller
    // ) external isOpen isReady {
    //     require(amountUSDC > 0, "Amount must be greater than zero");

    //     // Transfer USDC tokens from the user to the contract
    //     require(
    //         usdcToken.transferFrom(caller, address(this), amountUSDC),
    //         "Failed to transfer USDC tokens"
    //     );

    //     // Calculate the amount of Yes tokens to be received
    //     // uint256 amountYes = (amountUSDC * reserveYes) / (reserveNo);

    //     // reserveYes += amountYes;
    //     // reserveNo -= amountUSDC;

    //     // NoBalances[_msgSender()] -= amountUSDC;
    //     // YesBalances[_msgSender()] += amountUSDC;

    //     if (reserveNo * reserveYes != CONSTANT_K) revert PM_ConstantKViolated();

    //     // Emit SwapOrder event
    //     // emit SwapOrder(caller, amountUSDC, amountYes);
    // }

    // function buyNoWithUSDC(
    //     uint256 amountUSDC,
    //     address caller
    // ) external isOpen isReady {
    //     require(amountUSDC > 0, "Amount must be greater than zero");

    //     // Transfer USDC tokens from the user to the contract
    //     require(
    //         usdcToken.transferFrom(caller, address(this), amountUSDC),
    //         "Failed to transfer USDC tokens"
    //     );

    //     // Calculate the amount of No tokens to be received
    //     // uint256 amountNo = (amountUSDC * reserveNo) / (reserveYes);

    //     // reserveNo += amountNo;
    //     // reserveYes -= amountUSDC;

    //     // NoBalances[_msgSender()] += amountUSDC;
    //     // YesBalances[_msgSender()] -= amountUSDC;

    //     if (reserveNo * reserveYes != CONSTANT_K) revert PM_ConstantKViolated();

    //     // Emit SwapOrder event
    //     // emit SwapOrder(caller, amountUSDC, amountNo);
    // }

    // // External function to SwapOrder tokenNo for tokenYes
    // function swapNoForYes(
    //     uint256 amountA,
    //     address caller
    // ) external isOpen isReady {
    //     require(amountA > 0, "Amount must be greater than zero");

    //     // Calculate the amount of tokenYes to be received
    //     // uint256 amountB = (reserveYes * amountA) / reserveNo;

    //     // reserveNo += amountA;
    //     // reserveYes -= amountB;

    //     // NoBalances[_msgSender()] += amountA;
    //     // YesBalances[_msgSender()] -= amountA;

    //     if (reserveNo * reserveYes != CONSTANT_K) revert PM_ConstantKViolated();

    //     // emit SwapOrder(caller, amountA, amountB);
    // }

    // // External function to SwapOrder tokenYes for tokenNo
    // function swapYesForNo(
    //     uint256 amountB,
    //     address caller
    // ) external isOpen isReady {
    //     require(amountB > 0, "Amount must be greater than zero");

    //     // Calculate the amount of tokenNo to be received
    //     // uint256 amountA = (reserveNo * amountB) / reserveYes;

    //     // reserveNo -= amountA;
    //     // reserveYes += amountB;

    //     // NoBalances[_msgSender()] -= amountA;
    //     // YesBalances[_msgSender()] += amountA;

    //     if (reserveNo * reserveYes != CONSTANT_K) revert PM_ConstantKViolated();

    //     // Emit SwapOrder event
    //     // emit SwapOrder(caller, amountA, amountB);
    // }

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
