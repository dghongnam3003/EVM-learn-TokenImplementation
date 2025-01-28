async function main() {
  // Get the deployed NFT contract instance
  const nft = await ethers.getContractAt(
    "CustomERC721",
    "{ERC721 deployed address}"
  );

  const [owner, addr1] = await ethers.getSigners();
  console.log("Interacting with NFT using account:", owner.address);

  try {
    // Get basic contract info
    console.log("\nContract Info:");
    console.log("- Name:", await nft.name());
    console.log("- Symbol:", await nft.symbol());
    console.log("- Max Supply:", await nft.MAX_SUPPLY());
    console.log("- Base URI:", await nft.BASE_URI());
    console.log("- Current Total Supply:", await nft.totalSupply());

    // Mint some NFTs
    console.log("\nMinting NFTs...");
    
    // Mint first NFT with owner
    const tx1 = await nft.mint();
    const receipt1 = await tx1.wait();
    const mintedTokenId1 = await nft.balanceOf(owner.address);
    console.log(`Minted token #${mintedTokenId1} to ${owner.address}`);

    // Mint second NFT with addr1
    const tx2 = await nft.connect(addr1).mint();
    const receipt2 = await tx2.wait();
    const mintedTokenId2 = await nft.balanceOf(addr1.address);
    console.log(`Minted token #${mintedTokenId2} to ${addr1.address}`);

    // Get token URIs
    console.log("\nToken URIs:");
    console.log("Token #1:", await nft.tokenURI(1));
    console.log("Token #2:", await nft.tokenURI(2));

    // Check ownership
    console.log("\nOwnership Info:");
    console.log("Owner of Token #1:", await nft.ownerOf(1));
    console.log("Owner of Token #2:", await nft.ownerOf(2));

    // Check balances
    console.log("\nBalances:");
    console.log("Owner balance:", await nft.balanceOf(owner.address));
    console.log("Addr1 balance:", await nft.balanceOf(addr1.address));

    // Transfer an NFT
    console.log("\nTransferring NFT...");
    await nft.transferFrom(owner.address, addr1.address, 1);
    console.log("Transferred Token #1 from", owner.address, "to", addr1.address);

    // Check updated balances
    console.log("\nUpdated Balances:");
    console.log("Owner balance:", await nft.balanceOf(owner.address));
    console.log("Addr1 balance:", await nft.balanceOf(addr1.address));

    // Try to mint near max supply (for testing purposes)
    console.log("\nTesting max supply limit...");
    const currentSupply = await nft.totalSupply();
    const maxSupply = await nft.MAX_SUPPLY();
    console.log(`Current supply: ${currentSupply} / ${maxSupply}`);

  } catch (error) {
    console.error("\nError:", error.message);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });