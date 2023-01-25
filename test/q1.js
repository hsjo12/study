const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Q1", () => {
  let deployer, user;
  let q1NFT;
  before(async () => {
    [deployer, user] = await ethers.getSigners();
    const Q1NFT = await ethers.getContractFactory("Q1NFT");
    q1NFT = await Q1NFT.deploy();
    await q1NFT.deployed;
  });

  it("Check if NFT name and symbol are correct", async () => {
    expect(await q1NFT.name()).to.eq("SimpleNFT");
    expect(await q1NFT.symbol()).to.eq("SNFT");
  });

  it("Check if user1 can mint up to 10 for free", async () => {
    await q1NFT.connect(user).mint(10);
    expect(q1NFT.mint(1)).to.be.reverted;
    expect(await q1NFT.balanceOf(user.address)).to.eq(10);
  });

  it("chekc if tokenURI is working well", async () => {
    const tokenId = 10;
    expect(await q1NFT.tokenURI(tokenId)).to.eq(
      `ipfs://bafybeiczaoyuzf6x7shintdsn6amh2euojsijxdl7lnbvmnvn6dx2o53ry/${tokenId}.json`
    );
  });
});
