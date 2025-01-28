async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying NFT contract with the account:", deployer.address);

  // Deploy the CustomERC721 contract
  const CustomERC721 = await ethers.getContractFactory("CustomERC721");
  const nft = await CustomERC721.deploy("MyNFT", "MNFT");
  await nft.waitForDeployment();

  console.log("NFT contract address:", await nft.getAddress());
  
  // Log additional information
  console.log("\nContract details:");
  console.log("- Name:", await nft.name());
  console.log("- Symbol:", await nft.symbol());
  console.log("- Max supply:", await nft.MAX_SUPPLY());
  console.log("- Base URI:", await nft.BASE_URI());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });