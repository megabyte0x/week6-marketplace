// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Property.sol";

contract Marketplace is Ownable {
    Property property;

    mapping(uint256 => bool) onSale;

    constructor() {
        property = new Property();
    }

    /// @notice Function to get the address of the NFT collection deployed by this contract.
    function getPropertyAddress() public view returns (address) {
        return address(property);
    }

    function getOwner(uint256 tokenId) public view returns (address) {
        return property.ownerOf(tokenId);
    }

    /// @notice Function to mint the property as an NFT in the Property collection.
    /// @param _royalty Royalty percentage
    function mintProperty(
        uint256 _royalty,
        string calldata _name,
        string calldata _description,
        uint256 _dateOfTransfer,
        uint256 _salePrice
    ) external {
        property.safeMint(
            msg.sender,
            _royalty,
            _name,
            _description,
            _dateOfTransfer,
            _salePrice
        );
    }

    /// @notice Function to set royalty.
    /// @param tokenId Token id of the NFT
    /// @param royalty Royalty Percentage of the Sale Price
    function setRoyalty(uint256 tokenId, uint256 royalty) external {
        property.setRoyalty(tokenId, royalty);
    }

    /// @notice Function to put property on sale in the marketplace.
    /// @param _tokenId TokenId of the NFT
    function setPropertyOnSale(uint256 _tokenId) external {
        property.approve(address(this), _tokenId);
        onSale[_tokenId] = true;
    }

    /// @notice Function to buy property from marketplace with paying royalty to the first owner.
    /// @param _tokenId TokenId of the NFT
    function buyProperty(uint256 _tokenId) external payable {
        uint256 salePrice = property.getPropertyDetails(_tokenId).salePrice;
        require(onSale[_tokenId], "ERR:NS");
        (address firstOwner, uint256 royalAmount) = property.royaltyInfo(
            _tokenId,
            salePrice
        );
        uint256 totalAmount = salePrice + royalAmount;
        require(msg.value > totalAmount, "ERR:WV");

        (bool successRoyalty, ) = firstOwner.call{value: royalAmount}("");
        require(successRoyalty, "ERR:RT");

        (bool success, ) = property.ownerOf(_tokenId).call{value: salePrice}(
            ""
        );
        require(success, "ERR:ST");

        property.safeTransferFrom(firstOwner, msg.sender, _tokenId);
    }

    /// Function to start the rental agreement of the NFT for specific duration
    /// @param tokenId Token Id of the NFT
    /// @param _to The address of the renter
    /// @param expires Duration of the agreement
    function startRent(uint256 tokenId, address _to, uint256 expires) external {
        require(property.ownerOf(tokenId) == msg.sender, "ERR:NO");
        property.setUser(tokenId, _to, uint64(expires));
    }

    /// Function to check whether the propety is currently rented or not
    /// @param tokenId Token Id of the NFT
    function isRented(uint256 tokenId) external view returns (bool) {
        return address(0) != property.userOf(tokenId);
    }

    /// Function to check till what duration the property is rented.
    /// @param tokenId Token Id of the NFT
    function tillReneted(uint256 tokenId) external view returns (uint256) {
        return property.userExpires(tokenId);
    }
}
