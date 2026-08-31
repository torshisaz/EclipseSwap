const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EclipseSwap", function () {
  let token0, token1, swap, owner, user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("ERC20Mock");
    token0 = await Token.deploy("Token A", "TKA", ethers.parseEther("1000000"));
    token1 = await Token.deploy("Token B", "TKB", ethers.parseEther("1000000"));

    const Swap = await ethers.getContractFactory("EclipseSwap");
    swap = await Swap.deploy(token0.address, token1.address);
  });

  it("adds liquidity and receives shares", async function () {
    await token0.approve(swap.address, ethers.parseEther("1000"));
    await token1.approve(swap.address, ethers.parseEther("1000"));

    await swap.addLiquidity(ethers.parseEther("1000"), ethers.parseEther("1000"));

    const shares = await swap.balanceOf(owner.address);
    expect(shares).to.be.greaterThan(0);
  });

  it("swaps tokens", async function () {
    await token0.approve(swap.address, ethers.parseEther("1000"));
    await token1.approve(swap.address, ethers.parseEther("1000"));

    await swap.addLiquidity(ethers.parseEther("1000"), ethers.parseEther("1000"));

    await token0.approve(swap.address, ethers.parseEther("100"));
    await swap.swap(ethers.parseEther("100"), true);

    const balance1 = await token1.balanceOf(owner.address);
    expect(balance1).to.be.greaterThan(ethers.parseEther("999000"));
  });
});
