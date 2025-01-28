const { expect } = require("chai");

describe("CustomERC721", function () {
    let token;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        const CustomERC721 = await ethers.getContractFactory("CustomERC721");
        token = await CustomERC721.deploy("MyNFT", "MNFT");
    });

    describe("Deployment", function () {
        it("Should set the right name and symbol", async function () {
            expect(await token.name()).to.equal("MyNFT");
            expect(await token.symbol()).to.equal("MNFT");
        });
    });

    describe("Minting", function () {
        it("Should allow anyone to mint", async function () {
            await token.connect(addr1).mint();
            expect(await token.ownerOf(1)).to.equal(addr1.address);
        });

        it("Should increment token IDs correctly", async function () {
            await token.mint();
            await token.connect(addr1).mint();
            expect(await token.ownerOf(1)).to.equal(owner.address);
            expect(await token.ownerOf(2)).to.equal(addr1.address);
        });

        it("Should enforce max supply", async function () {
          // Increase the timeout for this specific test
          this.timeout(100000); // 100 seconds
  
          const maxSupply = await token.MAX_SUPPLY();
          const batchSize = 100n; // Convert to BigInt
          
          // Mint in batches until we reach near max supply
          for (let i = 0n; i < maxSupply - 1n; i += batchSize) { // Use BigInt
              const promises = [];
              // Convert the comparison to use BigInt
              for (let j = 0n; j < batchSize && (i + j) < maxSupply - 1n; j++) {
                  promises.push(token.mint());
              }
              await Promise.all(promises);
              
              // Optional: Log progress
              console.log(`Minted tokens: ${i + batchSize} / ${maxSupply}`);
          }
  
          // Mint one more token successfully
          await token.mint();
  
          // Try to mint one more token - should fail
          await expect(token.mint()).to.be.revertedWithCustomError(
              token,
              "MaxSupplyExceeded"
          );
      });
    });

    describe("Token URI", function () {
        it("Should return correct token URI", async function () {
            await token.mint();
            expect(await token.tokenURI(1)).to.equal("https://metadata.example/1");
        });
    });
});