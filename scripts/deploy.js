const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const [owner] = await hre.ethers.getSigners();

  const Q1NFT = await hre.ethers.getContractFactory("Q1NFT");
  const q1NFT = await Q1NFT.deploy();
  await q1NFT.deployed();
  const chainId = hre.network.config.chainId;
  CreateJs(q1NFT, "Q1NFT", chainId);
  console.log(q1NFT.address);
}

const CreateJs = async (contract, text, chainId) => {
  const artiPath = path.join(__dirname, "../frontend/artifacts/abis");

  if (!fs.existsSync(artiPath)) {
    fs.mkdirSync(artiPath, { recursive: true });
  }

  const artifacts = await hre.artifacts.readArtifact(text);
  // console.log(artifacts);
  artifacts.networkId = chainId;
  artifacts.address = contract.address;

  fs.writeFileSync(
    artiPath + `/${text}.json`,
    JSON.stringify(artifacts, null, 2)
  );
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
