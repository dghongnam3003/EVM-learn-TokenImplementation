const { expect } = require("chai");

describe("CustomERC20", function () {
  let token;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    token = await ethers.deployContract("CustomERC20", ["MyToken", "MTK"]);
  });

  describe("Deployment", function () {
    it("Should set the right name and symbol", async function () {
      expect(await token.name()).to.equal("MyToken");
      expect(await token.symbol()).to.equal("MTK");
    });

    it("Should assign the default admin role to the deployer", async function () {
      const DEFAULT_ADMIN_ROLE = ethers.ZeroHash;
      const hasRole = await token.hasRole(DEFAULT_ADMIN_ROLE, owner.address);
      expect(hasRole).to.be.true;
    });
  });

  describe("Minting", function () {
    it("Should allow minting by minter role", async function () {
      const MINTER_ROLE = await token.MINTER_ROLE();
      await token.grantRole(MINTER_ROLE, addr1.address);
      await token.connect(addr1).mint(addr2.address, 100);
      expect(await token.balanceOf(addr2.address)).to.equal(100);
    });
  });

  describe("Transfers", function () {
    beforeEach(async function () {
      const MINTER_ROLE = await token.MINTER_ROLE();
      await token.grantRole(MINTER_ROLE, owner.address);
      await token.mint(owner.address, 1000);
    });

    it("Should transfer tokens between accounts", async function () {
      await token.transfer(addr1.address, 50);
      expect(await token.balanceOf(addr1.address)).to.equal(50);
    });
  });
});