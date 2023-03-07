import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { abi } from "../artifacts/contracts/Property.sol/Property.json";

describe("Mint Property", function () {
  async function fixture() {
    const [deployer, user1, user2] = await ethers.getSigners();
    const royalty = 10;
    const name = "Test1";
    const description = "Test1D";
    const dateOfTransfer = time.latestBlock();
    const salePrice = ethers.utils.parseEther("1");

    const marketplaceContract = await ethers.getContractFactory("Marketplace");
    const marketplace = await marketplaceContract.deploy();
    await marketplace.deployed();

    const property = await ethers.getContractAt(
      abi,
      await marketplace.getPropertyAddress()
    );

    return {
      user1,
      user2,
      marketplace,
      property,
      royalty,
      name,
      description,
      dateOfTransfer,
      salePrice,
    };
  }

  it("Should mint the property", async () => {
    const {
      user1,
      user2,
      marketplace,
      property,
      royalty,
      name,
      description,
      dateOfTransfer,
      salePrice,
    } = await loadFixture(fixture);

    await marketplace
      .connect(user1)
      .mintProperty(royalty, name, description, dateOfTransfer, salePrice);
    console.log("minted1");
    await marketplace
      .connect(user2)
      .mintProperty(royalty, name, description, dateOfTransfer, salePrice);

    expect(await marketplace.getOwner(0)).to.be.equal(user1.address);
    expect(await marketplace.getOwner(1)).to.be.equal(user2.address);
  });
});
