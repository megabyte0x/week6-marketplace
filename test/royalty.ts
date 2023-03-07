import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { exec } from "child_process";
import { ethers } from "hardhat";

describe("Royalty", function () {
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

    return {
      user1,
      user2,
      marketplace,
      royalty,
      name,
      description,
      dateOfTransfer,
      salePrice,
    };
  }

  it("Should set the royalty amount to 20%", async () => {
    const {
      user1,
      marketplace,
      royalty,
      name,
      description,
      dateOfTransfer,
      salePrice,
    } = await loadFixture(fixture);

    await marketplace
      .connect(user1)
      .mintProperty(royalty, name, description, dateOfTransfer, salePrice)
      .then((tx) => {
        tx.wait();
        console.log("minted1");
      });

    await marketplace
      .connect(user1)
      .setRoyalty(0, 20)
      .then((tx) => {
        tx.wait();
        console.log("setted");
      })
      .catch((err) => {
        console.log(err);
      });

    const royaltyAmount = (await marketplace.getRoyaltyAmount(0, salePrice))[1];
    const royaltyReceiver = (
      await marketplace.getRoyaltyAmount(0, salePrice)
    )[0];

    expect(royaltyAmount).to.be.equal(ethers.utils.parseEther("0.2"));
    expect(royaltyReceiver).to.be.equal(user1.address);
  });
});
