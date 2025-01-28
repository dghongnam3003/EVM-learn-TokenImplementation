async function main() {
  // Get the deployed token instance
  const token = await ethers.getContractAt(
    "CustomERC20", 
    "0x0165878A594ca255338adfa4d48449f69242Eb8F"  // Token address
  );

  // Get signers
  const [owner, addr1] = await ethers.getSigners();
  console.log("Interacting with token using account:", owner.address);

  try {
    // Get basic token info
    const name = await token.name();
    const symbol = await token.symbol();
    const totalSupply = await token.totalSupply();
    console.log(`Token Info - Name: ${name}, Symbol: ${symbol}, Total Supply: ${totalSupply}`);

    // Grant minter role to owner
    const MINTER_ROLE = await token.MINTER_ROLE();
    await token.grantRole(MINTER_ROLE, owner.address);
    console.log("Granted minter role to:", owner.address);

    // Mint tokens
    const mintAmount = ethers.parseEther("1000");
    await token.mint(owner.address, mintAmount);
    console.log("Minted:", ethers.formatEther(mintAmount), "tokens to", owner.address);

    // Check balance
    const balance = await token.balanceOf(owner.address);
    console.log("Balance:", ethers.formatEther(balance));

    // Transfer tokens
    if (addr1) {
      const transferAmount = ethers.parseEther("100");
      await token.transfer(addr1.address, transferAmount);
      console.log("Transferred:", ethers.formatEther(transferAmount), "tokens to", addr1.address);
      
      const addr1Balance = await token.balanceOf(addr1.address);
      console.log("Recipient balance:", ethers.formatEther(addr1Balance));
    }

  } catch (error) {
    console.error("Error:", error.message);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });


// Interact with another role - not MINTER_ROLE
// async function main() {
//   const token = await ethers.getContractAt(
//     "CustomERC20", 
//     "token address"
//   );

//   const [owner] = await ethers.getSigners();
//   console.log("Interacting with token using account:", owner.address);

//   try {
//     // Check if the account has MINTER_ROLE
//     const MINTER_ROLE = await token.MINTER_ROLE();
//     const hasMinterRole = await token.hasRole(MINTER_ROLE, owner.address);
//     console.log("Has MINTER_ROLE:", hasMinterRole);

//     // Check if the account has DEFAULT_ADMIN_ROLE
//     const DEFAULT_ADMIN_ROLE = await token.DEFAULT_ADMIN_ROLE();
//     const hasAdminRole = await token.hasRole(DEFAULT_ADMIN_ROLE, owner.address);
//     console.log("Has DEFAULT_ADMIN_ROLE:", hasAdminRole);

//     // Try to mint tokens
//     console.log("\nAttempting to mint without MINTER_ROLE...");
//     const mintAmount = ethers.parseEther("1000");
    
//     try {
//       await token.mint(owner.address, mintAmount);
//       console.log("Minting succeeded (this shouldn't happen!)");
//     } catch (error) {
//       console.log("Minting failed as expected:", error.message);
//     }

//     // Check balance
//     const balance = await token.balanceOf(owner.address);
//     console.log("\nBalance:", ethers.formatEther(balance));
//   } catch (error) {
//     console.error("Error:", error.message);
//   }
// }

// main()
//   .then(() => process.exit(0))
//   .catch((error) => {
//     console.error(error);
//     process.exit(1);
//   });