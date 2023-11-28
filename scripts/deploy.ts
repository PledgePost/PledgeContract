import { ethers } from "hardhat";

async function getNonce() {
  const signer = (await ethers.getSigners())[0];
  const currentNonce = await ethers.provider.getTransactionCount(
    signer.address
  );
  console.log(`Current nonce: ${currentNonce}`);
}

async function main() {
  // Hardcoded deploying nonce
  const deployNonce = 50;

  const signer = (await ethers.getSigners())[0];
  const currentNonce = await ethers.provider.getTransactionCount(
    signer.address
  );
  console.log(`Current nonce: ${currentNonce}`);

  if (currentNonce > deployNonce) {
    throw new Error(
      `Current nonce ${currentNonce} is greater than desired nonce ${deployNonce}`
    );
  }

  for (let i = currentNonce; i < deployNonce; i++) {
    const tx = await signer.sendTransaction({
      to: signer.address,
      value: 0,
    });
    await tx.wait();
    console.log(`Nonce ${i} sent`);
  }
  // Now deploy the main contract
  const ContractFactory = await ethers.getContractFactory("PledgePost");
  const contract = await ContractFactory.deploy({ nonce: deployNonce });
  console.log(`Contract deployed at address: ${contract.target}`);
}

async function setup() {
  let contractAddress = "0x7c1a2f6bb2E01fc051298bCB279008ffC256d35f";
  // let tokenAddress = "0xD4978Df429A81Fb2032C0416D6bD854E1f93EcAa";

  const contract = await ethers.getContractAt("PledgePost", contractAddress);
  // const tokenContract = await ethers.getContractAt("TestToken", tokenAddress);
  const tx1 = await contract.createRound(
    "Initial Round",
    "This is the first round of the PledgePost! Enjoy to write something awesome!",
    1699509663,
    1702101663
  );
  await tx1.wait();
  console.log(`Round 1 created`);
  const tx2 = await contract.activateRound(1);
  await tx2.wait();
  console.log(`Round 1 activated`);
}

async function allocate() {
  let contractAddress = "0x7c1a2f6bb2E01fc051298bCB279008ffC256d35f";
  const contract = await ethers.getContractAt("PledgePost", contractAddress);
  const tx1 = await contract.Allocate(1);
  const txreceipt = await tx1.wait();
  console.log(`Round 1 Allocated`, txreceipt);
}

main()
  // setup()
  // allocate()
  // getNonce()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

/*
npx hardhat run scripts/deploy.ts --network goerli
npx hardhat run scripts/deploy.ts --network sepolia
npx hardhat run scripts/deploy.ts --network optimismGoerli
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
