import { ethers } from "hardhat";

async function main() {
  // Hardcoded deploying nonce
  const deployNonce = 14;

  const signer = (await ethers.getSigners())[0];

  // Check if signer nonce matches desired nonce
  const nonce = await ethers.provider.getTransactionCount(signer.address);
  if (nonce !== deployNonce) {
    throw new Error(
      `Signer nonce ${nonce} is different from desired nonce ${deployNonce}`
    );
  }

  // Now deploy the main contract
  const ContractFactory = await ethers.getContractFactory("TestToken");
  const contract = await ContractFactory.deploy({ nonce: deployNonce });

  console.log(`Contract deployed at address: ${contract.target}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
/*
npx hardhat run scripts/deployToken.ts --network goerli
npx hardhat run scripts/deployToken.ts --network sepolia
npx hardhat run scripts/deployToken.ts --network polygonMumbai
npx hardhat run scripts/deployToken.ts --network polygonZkEvmTestnet
npx hardhat run scripts/deployToken.ts --network scrollSepolia
npx hardhat run scripts/deployToken.ts --network optimismGoerli
*/
