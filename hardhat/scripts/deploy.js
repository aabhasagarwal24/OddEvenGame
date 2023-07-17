const { ethers }= require("hardhat");
require("dotenv").config({ path: ".env" });

async function main() {

  const votingContract = await ethers.getContractFactory("voting");

  const deployedvotingContract = await votingContract.deploy(10,20);

  // Wait for it to finish deploying
  await deployedvotingContract.deployed();

  // print the address of the deployed contract
  console.log("Voting Contract Address:", deployedvotingContract.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });