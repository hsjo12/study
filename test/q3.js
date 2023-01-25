const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("q3", () => {
  let deployer, user1;
  let q3NFT, primeNumberTokenIdChekcer;

  before(async () => {
    [deployer, user1] = await ethers.getSigners();
    const Q3NFT = await ethers.getContractFactory("Q3NFT");
    q3NFT = await Q3NFT.deploy();
    q3NFT.deployed();

    const PrimeNumberTokenIdChekcer = await ethers.getContractFactory(
      "PrimeNumberTokenIdChekcer"
    );
    primeNumberTokenIdChekcer = await PrimeNumberTokenIdChekcer.deploy(
      q3NFT.address
    );
    primeNumberTokenIdChekcer.deployed();
  });

  it("user1 mint all the NFTs(20Nfts) and check the prime number of NFT id", async () => {
    await q3NFT.connect(user1).mint(20);
    expect(await q3NFT.balanceOf(user1.address)).to.eq(20);
    const primeNumbersTill20 = [2, 3, 5, 7, 11, 13, 17, 19];
    const primeNumbers =
      await primeNumberTokenIdChekcer.checkPrimeNumberTokenIds(user1.address);
    expect(primeNumbersTill20).to.deep.equal(primeNumbers);
  });
});
