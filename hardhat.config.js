require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
/** @type import('hardhat/config').HardhatUserConfig */
require("dotenv").config();

module.exports = {
  networks: {
    hardhat: {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.FORKING_KEY}`,
      },
    },
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${process.env.GOERLI_KEY}`,
      accounts: [process.env.PRIVATE_KEY],
    },
  },

  gasReporter: {
    enabled: true,
    currency: "ETH",
    coinmarketcap: process.env.COIN_MARKET_CAP_KEY,
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  mocha: {
    timeout: 4000000,
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHER_SCAN_MAINNET_KEY,
      goerli: process.env.ETHER_SCAN_MAINNET_KEY,
    },
  },
};
