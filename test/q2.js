const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("q2", () => {
  const MANAGE =
    "0xaf290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c";
  const PRICE = ethers.utils.parseEther("0.01");
  let deployer, user1, user2, user3;
  let q2NFT, rewards, stake;

  before(async () => {
    [deployer, user1, user2, user3] = await ethers.getSigners();
    const Q2NFT = await ethers.getContractFactory("Q2NFT");
    q2NFT = await Q2NFT.deploy();
    await q2NFT.deployed();

    const Rewards = await ethers.getContractFactory("Rewards");
    rewards = await Rewards.deploy();
    await rewards.deployed();

    const Stake = await ethers.getContractFactory("Stake");
    stake = await Stake.deploy(rewards.address, q2NFT.address);
    rewards.grantRole(MANAGE, stake.address);
  });

  it("user1, user2, user3 mint nfts", async () => {
    await q2NFT.connect(user1).mint(1, { value: PRICE });
    await q2NFT.connect(user2).mint(2, { value: PRICE.mul(2) });
    await q2NFT.connect(user3).mint(3, { value: PRICE.mul(3) });
    expect(await q2NFT.ownerOf(1)).to.eq(user1.address);
    expect(await q2NFT.ownerOf(2)).to.eq(user2.address);
    expect(await q2NFT.ownerOf(3)).to.eq(user2.address);
    expect(await q2NFT.ownerOf(4)).to.eq(user3.address);
    expect(await q2NFT.ownerOf(5)).to.eq(user3.address);
    expect(await q2NFT.ownerOf(6)).to.eq(user3.address);

    expect(await q2NFT.balanceOf(user1.address)).to.eq(1);
    expect(await q2NFT.balanceOf(user2.address)).to.eq(2);
    expect(await q2NFT.balanceOf(user3.address)).to.eq(3);
  });
  it("user1 and user2 stake their nft", async () => {
    await q2NFT
      .connect(user1)
      ["safeTransferFrom(address,address,uint256)"](
        user1.address,
        stake.address,
        1
      );

    await q2NFT
      .connect(user2)
      ["safeTransferFrom(address,address,uint256)"](
        user2.address,
        stake.address,
        2
      );

    await q2NFT
      .connect(user2)
      ["safeTransferFrom(address,address,uint256)"](
        user2.address,
        stake.address,
        3
      );

    expect(await stake.stakingNumberOf(user1.address)).to.eq(1);
    expect(await stake.stakingNumberOf(user2.address)).to.eq(2);
  });

  it("user3 stakes 2 nfts of user3 at once ", async () => {
    const tokeIdsOfUser3 = [4, 5];
    await q2NFT.connect(user3).setApprovalForAll(stake.address, true);
    await stake.connect(user3).stakingNfts(tokeIdsOfUser3);
    expect(await stake.stakingNumberOf(user3.address)).to.eq(2);
  });

  it("After 24 hours, check reward tokens", async () => {
    console.log("After 24 hours");
    const ONE_DAY = 86400;
    await ethers.provider.send("evm_increaseTime", [ONE_DAY]);
    await ethers.provider.send("evm_mine");

    console.log("user3 decided to stake 1 nft");
    await q2NFT
      .connect(user3)
      ["safeTransferFrom(address,address,uint256)"](
        user3.address,
        stake.address,
        6
      );

    const currentRewardsOfUser1 = await stake.rewardsOf(user1.address);
    const currentRewardsOfUser2 = await stake.rewardsOf(user2.address);
    const currentRewardsOfUser3 = await stake.rewardsOf(user3.address);

    expect(currentRewardsOfUser1).to.eq(ethers.utils.parseEther("10"));
    expect(currentRewardsOfUser2).to.eq(ethers.utils.parseEther("20"));
    expect(currentRewardsOfUser3).to.eq(ethers.utils.parseEther("20"));

    console.log(
      `User1 staked 1 nft for 24 hours, and can claim  ${ethers.utils.formatEther(
        currentRewardsOfUser1
      )} reward tokens`
    );

    console.log(
      `User2 staked 2 nft for 24 hours, and can claim  ${ethers.utils.formatEther(
        currentRewardsOfUser2
      )} reward tokens`
    );

    console.log(
      `User3 staked 2 nft for 24 hours and staked 1 nft just now, and can claim  ${ethers.utils.formatEther(
        currentRewardsOfUser3
      )} reward tokens`
    );
  });

  it("User1 claimed rewards", async () => {
    const balanceOfUser1_1 = await rewards.balanceOf(user1.address);
    console.log(`user1's balance ${balanceOfUser1_1} reward tokens`);
    await stake.connect(user1).claimRewards();
    console.log(`After Claim reward tokens`);
    const balanceOfUser1_2 = await rewards.balanceOf(user1.address);
    console.log(
      `user1's balance  ${ethers.utils.formatEther(
        balanceOfUser1_2
      )} reward tokens`
    );

    expect(balanceOfUser1_1).to.eq(0);
    expect(balanceOfUser1_2).to.eq(ethers.utils.parseEther("10"));
  });

  it("user2 withdraw 1 staked nft out of 2 staked NFTs without claming rewards", async () => {
    const balanceOfUser2_1 = await rewards.balanceOf(user2.address);
    console.log(
      `user2's balance ${ethers.utils.formatEther(
        balanceOfUser2_1
      )} reward tokens`
    );
    console.log(`After Withdraw a single NFT`);
    await stake.connect(user2).withdrawNFT(2);
    const balanceOfUser2_2 = await rewards.balanceOf(user2.address);
    console.log(
      `user2's balance ${ethers.utils.formatEther(
        balanceOfUser2_2
      )} reward tokens`
    );
    expect(balanceOfUser2_1).to.eq(0);
    expect(balanceOfUser2_2).to.eq(ethers.utils.parseEther("10"));
  });

  it.only("user3 mints and stake nfts", async () => {
    await q2NFT.connect(user3).mint(20, { value: PRICE.mul(20) });
    expect(await q2NFT.balanceOf(user3.address)).to.eq(20);

    for (let i = 1; i < 11; i++) {
      await q2NFT
        .connect(user3)
        ["safeTransferFrom(address,address,uint256)"](
          user3.address,
          stake.address,
          i
        );
    }
    const tokeIdsOfUser3 = [11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
    await q2NFT.connect(user3).setApprovalForAll(stake.address, true);
    await stake.connect(user3).stakingNfts(tokeIdsOfUser3);
  });
});
