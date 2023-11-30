const { ethers, upgrades } = require("hardhat");

async function main() {
  const ContractFactory = await ethers.getContractFactory("PledgePost");
  const contract = await upgrades.deployProxy(ContractFactory, [
    "0x9B789cc315F1eedFbCBE759DEbb5a3D5D41B788f",
  ]);
  await contract.waitForDeployment();

  console.log("Contract deployed to:", await contract.getAddress());
}
async function upgrade() {
  const ContractFactory = await ethers.getContractFactory("PledgePost");
  const contract = await upgrades.upgradeProxy(
    "0x01139EdF0Cca71fd0A0e59C694332a68Dc10a3f4",
    ContractFactory
  );
  console.log("implementation upgraded to:", await contract.getAddress());
}
async function initialize() {
  let contractAddress = "0x01139EdF0Cca71fd0A0e59C694332a68Dc10a3f4";

  const contract = await ethers.getContractAt("PledgePost", contractAddress);

  const tx1 = await contract.postArticle(contractAddress);
  await tx1.wait();
  console.log(`Article posted`);
}

// main()
initialize()
  // upgrade()
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
