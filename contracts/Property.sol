// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./ERC4907.sol";

contract Property is ERC721, ERC721Royalty, ERC4907, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct PropertyDetails {
        string name;
        string description;
        uint256 dateOfTransfer;
        uint256 salePrice;
    }

    mapping(uint256 => PropertyDetails) propertyDetails;

    constructor() ERC4907("Property Token", "PT") {}

    /// @notice Safe Mint with the tokenURI containg the metadata

    function safeMint(
        address to,
        uint256 royalty,
        string calldata _name,
        string calldata _description,
        uint256 _dateOfTransfer,
        uint256 _salePrice
    ) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenRoyalty(tokenId, msg.sender, uint96(royalty));
        propertyDetails[tokenId] = PropertyDetails({
            name: _name,
            description: _description,
            dateOfTransfer: _dateOfTransfer,
            salePrice: _salePrice
        });
    }

    /// @notice Function to set royalty.
    /// @param tokenId Token id of the NFT
    /// @param royalty Royalty Percentage of the Sale Price
    function setRoyalty(
        uint256 tokenId,
        address receiver,
        uint256 royalty
    ) external {
        _setTokenRoyalty(tokenId, receiver, uint96(royalty));
    }

    // function getSalePrice(uint256 tokenId) external view returns (uint256) {
    //     return propertyDetails[tokenId].salePrice;
    // }

    function getPropertyDetails(
        uint256 tokenId
    ) external view returns (PropertyDetails memory) {
        return propertyDetails[tokenId];
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC4907) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721) returns (string memory) {
        _requireMinted(tokenId);
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Royalty, ERC721, ERC4907)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Royalty) {
        super._burn(tokenId);
    }
}
