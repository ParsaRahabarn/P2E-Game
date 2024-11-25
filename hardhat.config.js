/** @type import('hardhat/config').HardhatUserConfig */
// require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-ethers");
require('dotenv')
// require('@nomiclabs/hardhat-waffle');
// const ethers = require('ethers')
require("@nomicfoundation/hardhat-toolbox");
// require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.20",
  defaultNetwork: "hardhat",
  paths: {
    artifacts: "./artifacts",
    sources: "./contracts",
  },
  networks: {
    hardhat: {
      chainId: 1337,

      localhost: {
        url: "http://127.0.0.1:8545",
        chainId: 1337,
      },
      
      
    },
    mumbai:{
        url: "https://polygon-mumbai-pokt.nodies.app",
        accounts: [
        // process.env.PV,
        ],
      }

    
  },
  etherscan: {
    // apiKey: process.env.SC
  }
};
