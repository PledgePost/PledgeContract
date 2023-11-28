const { ethers, upgrades } = require("hardhat");

async function main() {
  const ContractFactory = await ethers.getContractFactory("PledgePost");
  const contract = await upgrades.deployProxy(ContractFactory, [
    "0x9B789cc315F1eedFbCBE759DEbb5a3D5D41B788f",
  ]);
  await contract.deployed();
  console.log(`Contract deployed at address: ${contract.address}`);
}
async function upgrade() {
  const ContractFactory = await ethers.getContractFactory("PledgePost");
  const contract = await upgrades.upgradeProxy(
    "primary contract address",
    ContractFactory
  );
  console.log(`Contract upgraded at address: ${contract.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

/*
	npx hardhat run scripts/deployUpgradable.ts --network goerli
	npx hardhat run scripts/deployUpgradable.ts --network sepolia
	npx hardhat run scripts/deployUpgradable.ts --network optimismGoerli
	npx hardhat run scripts/deployUpgradable.ts --network polygonMumbai
	npx hardhat run scripts/deployUpgradable.ts --network polygonZkEvmTestnet
	npx hardhat run scripts/deployUpgradable.ts --network scrollSepolia
*/
