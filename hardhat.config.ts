import * as dotenv from "dotenv";
dotenv.config();
import { HardhatUserConfig } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-toolbox";
const providerApiKey = process.env.PROVIDER_API_KEY as string;
const deployerPrivateKey = process.env.DEPLOYER_PRIVATE_KEY as string;
const etherscanApiKey = process.env.ETHERSCAN_API_KEY as string;
const gasLimit = 60000000;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  networks: {
    // mainnet: {
    //   url: `https://mainnet.infura.io/v3/{providerApiKey}`,
    //   accounts: [deployerPrivateKey],
    // },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${providerApiKey}`,
      accounts: [deployerPrivateKey],
      blockGasLimit: gasLimit,
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${providerApiKey}`,
      accounts: [deployerPrivateKey],
      blockGasLimit: gasLimit,
    },
    optimism: {
      url: `https://optimism-mainnet.infura.io/v3/${providerApiKey}`,
      accounts: [deployerPrivateKey],
      blockGasLimit: gasLimit,
    },
    optimismGoerli: {
      url: `https://optimism-goerli.infura.io/v3/${providerApiKey}`,
      accounts: [deployerPrivateKey],
      blockGasLimit: gasLimit,
    },
    polygon: {
      url: `https://polygon-mainnet.infura.io/v3/${providerApiKey}`,
      accounts: [deployerPrivateKey],
      blockGasLimit: gasLimit,
    },
    polygonMumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${providerApiKey}`,
      accounts: [deployerPrivateKey],
      blockGasLimit: gasLimit,
    },
    polygonZkEvm: {
      url: "https://zkevm-rpc.com",
      accounts: [deployerPrivateKey],
      blockGasLimit: gasLimit,
    },
    polygonZkEvmTestnet: {
      url: "https://rpc.public.zkevm-test.net",
      accounts: [deployerPrivateKey],
      blockGasLimit: gasLimit,
    },
    scrollSepolia: {
      url: "https://sepolia-rpc.scroll.io",
      accounts: [deployerPrivateKey],
      blockGasLimit: gasLimit,
    },
  },
  etherscan: {
    apiKey: {
      mainnet: etherscanApiKey,
      sepolia: etherscanApiKey,
      goerli: etherscanApiKey,
      optimism: process.env.ETHERSCAN_OPTIMISM_API_KEY as string,
      optimismGoerli: process.env.ETHERSCAN_OPTIMISM_API_KEY as string,
      polygon: process.env.ETHERSCAN_POLYGON_API_KEY as string,
      polygonMumbai: process.env.ETHERSCAN_POLYGON_API_KEY as string,
      polygonZkEvm: process.env.ETHERSCAN_POLYGON_ZKEVM_API_KEY as string,
      polygonZkEvmTestnet: process.env
        .ETHERSCAN_POLYGON_ZKEVM_API_KEY as string,
      scrollSepolia: "D62920783A4311EE9D6600155D570C742E",
    },
    customChains: [
      {
        network: "goerli",
        chainId: 5,
        urls: {
          apiURL: "https://api-goerli.etherscan.io/api",
          browserURL: "https://goerli.etherscan.io",
        },
      },
      {
        network: "optimismGoerli",
        chainId: 420,
        urls: {
          apiURL: "https://api-goerli-optimistic.etherscan.io/api",
          browserURL: "https://goerli-optimistic.etherscan.io",
        },
      },
      {
        network: "polygonMumbai",
        chainId: 80001,
        urls: {
          apiURL: "https://api-mumbai.polygonscan.com/api",
          browserURL: "https://mumbai.polygonscan.com",
        },
      },
      {
        network: "polygonZkEvmTestnet",
        chainId: 1442,
        urls: {
          apiURL: "https://api-testnet-zkevm.polygonscan.com/api",
          browserURL: "https://testnet-zkevm.polygonscan.com/",
        },
      },
      {
        network: "scrollSepolia",
        chainId: 1337,
        urls: {
          apiURL: "https://api-sepolia.scrollscan.dev/api",
          browserURL: "https://sepolia.scrollscan.com",
        },
      },
    ],
  },
};

export default config;
