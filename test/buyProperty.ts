import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

describe("Buy Property", function () {
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
      "Property",
      await marketplace.getPropertyAddress()
    );

    await marketplace
      .connect(user1)
      .mintProperty(royalty, name, description, dateOfTransfer, salePrice)
      .then((tx) => {
        tx.wait();
        console.log("Minted Property");
      });

    await marketplace
      .connect(user1)
      .setRoyalty(0, 20)
      .then((tx) => {
        tx.wait();
        console.log("Royalty setted");
      });

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

  it("Should buy the property", async () => {
    const { user1, user2, marketplace, property, royalty, salePrice } =
      await loadFixture(fixture);

    const buyPrice = ethers.BigNumber.from(salePrice).add(
      BigNumber.from(salePrice).div(royalty).mul(100)
    );

    await property
      .connect(user1)
      .approve(marketplace.address, 0)
      .then((tx) => {
        tx.wait();
        console.log("approved");
      })
      .catch((err) => {
        console.log(err);
      });

    await marketplace.connect(user1).setPropertyOnSale(0);

    await marketplace
      .connect(user2)
      .buyProperty(0, { value: buyPrice })
      .catch((err) => {
        console.error(err);
      });

    expect(await marketplace.getOwner(0)).to.be.equal(user2.address);
  });
});
