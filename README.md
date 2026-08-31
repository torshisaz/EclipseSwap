# EclipseSwap

A minimal automated market maker (AMM) decentralized exchange. Built for learning, not production.

## Overview

EclipseSwap implements a constant-product AMM similar to Uniswap v2. Liquidity providers deposit pairs of tokens and earn fees on trades. Traders swap tokens against the pool at market-determined prices.

## Core mechanics

- **Constant product formula**: `x * y = k` must hold after every trade
- **Liquidity tokens**: LPs receive shares proportional to their contribution
- **Swap fees**: 0.3% on each trade, distributed to LPs
- **Price impact**: Larger trades move the price more

## Structure

```
contracts/
  EclipseSwap.sol    Core AMM logic
  ERC20Mock.sol      Test tokens
scripts/
  deploy.js          Deployment script
tests/
  swap.test.js       Swap and LP tests
```

## Quick start

```bash
npm install
npx hardhat compile
npx hardhat test
```

## License

MIT
