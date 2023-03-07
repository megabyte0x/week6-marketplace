import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Deploy", function () {
  it("Should deploy all the contracts", async function () {
    const [deployer] = await ethers.getSigners();

    const marketPlaceContract = await ethers.getContractFactory("Marketplace");
    const marketplace = await marketPlaceContract.deploy();
    await marketplace.deployed();

    console.log("Marketplace deployed to:", marketplace.address);
    console.log(
      "Property deployed to:",
      await marketplace.getPropertyAddress()
    );
  });
});
