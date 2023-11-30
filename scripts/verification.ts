import { ethers } from "hardhat";

async function main() {
  const ContractFactory = await ethers.getContractFactory("EASVerification");
  const deployer = await ContractFactory.deploy(
    // EAS contract on OP mainnet
    "0x4200000000000000000000000000000000000021"
  );
  console.log(`Contract deployed at address: ${deployer.target}`);
}

async function getScore() {
  const contract = await ethers.getContractAt(
    "EASVerification",
    "0x4c952fCbbccde7d0B87eD716c33360cAa6C056f0"
  );
  const score = await contract.getPassportAttestation(
    "0xc3f45c5af0a43a9575e6fc92d84ecb2ffdd77b568bea27d06cb00b71e3d7f68b",
    "0x63b1EfC5602C0023BBb373F2350Cf34c2E5F8669"
  );
  console.log("score: ", score);
  // score:  37n
}

// main()
getScore()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

/*
npx hardhat run scripts/verification.ts --network optimism

npx hardhat run scripts/deploy.ts --network goerli
npx hardhat run scripts/deploy.ts --network sepolia
npx hardhat run scripts/deploy.ts --network polygonMumbai
npx hardhat run scripts/deploy.ts --network polygonZkEvmTestnet
npx hardhat run scripts/deploy.ts --network scrollSepolia
*/
/*
npx hardhat verify --network goerli 0xE0d890590B2d3f9914628C7CC62DeDEddDfe5Fa5
npx hardhat verify --network sepolia 0x298005746ff8C64252c1398e24eA5C17541db1B5
npx hardhat verify --network optimismGoerli 0xD4978Df429A81Fb2032C0416D6bD854E1f93EcAa
npx hardhat verify --network polygonMumbai 0xD4978Df429A81Fb2032C0416D6bD854E1f93EcAa
npx hardhat verify --network polygonZkEvmTestnet 0x7c1a2f6bb2E01fc051298bCB279008ffC256d35f
npx hardhat verify --network scrollSepolia 0x7c1a2f6bb2E01fc051298bCB279008ffC256d35f
*/
