// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EclipseSwap is ReentrancyGuard {
    IERC20 public token0;
    IERC20 public token1;
    
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    
    event Swap(address indexed user, uint256 amountIn, uint256 amountOut, bool isToken0);
    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 shares);
    event LiquidityRemoved(address indexed provider, uint256 shares, uint256 amount0, uint256 amount1);
    
    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }
    
    function addLiquidity(uint256 amount0, uint256 amount1) external nonReentrant returns (uint256 shares) {
        require(amount0 > 0 && amount1 > 0, "Invalid amounts");
        
        token0.transferFrom(msg.sender, address(this), amount0);
        token1.transferFrom(msg.sender, address(this), amount1);
        
        if (totalSupply == 0) {
            shares = sqrt(amount0 * amount1);
        } else {
            shares = min(
                (amount0 * totalSupply) / reserve0,
                (amount1 * totalSupply) / reserve1
            );
        }
        
        require(shares > 0, "No shares");
        
        balanceOf[msg.sender] += shares;
        totalSupply += shares;
        reserve0 += amount0;
        reserve1 += amount1;
        
        emit LiquidityAdded(msg.sender, amount0, amount1, shares);
    }
    
    function removeLiquidity(uint256 shares) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        require(balanceOf[msg.sender] >= shares, "Insufficient shares");
        require(shares > 0, "Zero shares");
        
        amount0 = (shares * reserve0) / totalSupply;
        amount1 = (shares * reserve1) / totalSupply;
        
        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;
        reserve0 -= amount0;
        reserve1 -= amount1;
        
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
        
        emit LiquidityRemoved(msg.sender, shares, amount0, amount1);
    }
    
    function swap(uint256 amountIn, bool isToken0) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "Zero input");
        
        IERC20 tokenIn = isToken0 ? token0 : token1;
        IERC20 tokenOut = isToken0 ? token1 : token0;
        uint256 reserveIn = isToken0 ? reserve0 : reserve1;
        uint256 reserveOut = isToken0 ? reserve1 : reserve0;
        
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        
        // 0.3% fee
        uint256 amountInWithFee = amountIn * 997;
        amountOut = (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);
        
        require(amountOut > 0, "Zero output");
        
        if (isToken0) {
            reserve0 += amountIn;
            reserve1 -= amountOut;
        } else {
            reserve1 += amountIn;
            reserve0 -= amountOut;
        }
        
        tokenOut.transfer(msg.sender, amountOut);
        emit Swap(msg.sender, amountIn, amountOut, isToken0);
    }
    
    function getReserves() external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }
    
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
