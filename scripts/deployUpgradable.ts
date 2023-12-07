const { ethers, upgrades } = require("hardhat");

async function main() {
  const ContractFactory = await ethers.getContractFactory("PledgePost");
  const contract = await upgrades.deployProxy(ContractFactory, [
    "0x9B789cc315F1eedFbCBE759DEbb5a3D5D41B788f",
    ethers.parseEther("0.0005"),
  ]);
  await contract.waitForDeployment();

  console.log("Contract deployed to:", await contract.getAddress());
}

async function upgrade() {
  const ContractFactory = await ethers.getContractFactory("PledgePost");
  const contract = await upgrades.upgradeProxy(
    "0xD62087Bf50dCd6dD87f96E21d1AD040bD9c99589",
    ContractFactory
  );
  console.log("implementation upgraded to:", await contract.getAddress());
}
async function initialize() {
  let contractAddress = "0xD62087Bf50dCd6dD87f96E21d1AD040bD9c99589";

  const contract = await ethers.getContractAt("PledgePost", contractAddress);

  const tx1 = await contract.postArticle(contractAddress);
  await tx1.wait();
  console.log(`Article posted`);
}
async function addAdmin() {
  let contractAddress = "0xD62087Bf50dCd6dD87f96E21d1AD040bD9c99589";

  const contract = await ethers.getContractAt("PledgePost", contractAddress);

  const tx1 = await contract.addAdmin(
    "0x06aa005386F53Ba7b980c61e0D067CaBc7602a62"
  );
  await tx1.wait();
  console.log(`Admin added`);
}

// main()
// initialize()
// upgrade()
addAdmin()
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
