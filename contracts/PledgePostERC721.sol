// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import {IPledgePostERC721} from "./interface/IPledgePostERC721.sol";

contract PledgePostERC721 is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable,
    IPledgePostERC721
{
    using Strings for uint256;
    address private _owner;
    uint256 private _tokenIdCounter;
    string private _defaultImageUrl;

    mapping(uint256 => TokenData) private _tokenData;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address owner,
        string memory defaultImageUrl
    ) public initializer {
        __Ownable_init(owner);
        __ERC721_init("PledgePost Donation NFT", "PLPDNFT");
        _defaultImageUrl = defaultImageUrl;
        _owner = owner;
    }

    function setImageUrl(
        uint256 tokenId,
        string memory imageUrl
    ) external onlyOwner {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        TokenData storage tokenData = _tokenData[tokenId];
        tokenData.imageUrl = imageUrl;
    }

    function setDefaultImageUrl(
        string memory defaultImageUrl
    ) external onlyOwner {
        _defaultImageUrl = defaultImageUrl;
    }

    function mint(
        address minterAddress,
        address authorAddress,
        uint256 articleId,
        bytes calldata contentURI
    ) external onlyOwner returns (uint256) {
        require(minterAddress != address(0), "Minter address is zero");
        require(authorAddress != address(0), "Author address is zero");
        require(contentURI.length > 0, "ContentURI is empty");
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;
        _safeMint(minterAddress, tokenId);

        TokenData storage tokenData = _tokenData[tokenId];
        tokenData.minterAddress = minterAddress;
        tokenData.contentURI = contentURI;
        tokenData.authorAddress = authorAddress;
        tokenData.articleId = articleId;

        if (bytes(tokenData.imageUrl).length == 0) {
            tokenData.imageUrl = _defaultImageUrl;
        }
        emit Minted(
            minterAddress,
            tokenId,
            authorAddress,
            articleId,
            block.timestamp
        );
        return tokenId;
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        override(ERC721Upgradeable, IPledgePostERC721)
        returns (string memory)
    {
        TokenData memory tokenData = _tokenData[tokenId];

        bytes memory attributes = abi.encodePacked(
            '{"trait_type": "ID", "value": "',
            tokenId.toString(),
            '"},',
            '{"trait_type": "name", "value": "',
            "PledgePost Donation NFT",
            '"}',
            '{"trait_type": "author", "value": "',
            tokenData.authorAddress,
            '"}'
            '{"trait_type": "articleId", "value": "',
            tokenData.articleId.toString(),
            '"}'
        );

        string memory imageUrl = bytes(tokenData.imageUrl).length > 0
            ? tokenData.imageUrl
            : _defaultImageUrl;

        bytes memory metadata = abi.encodePacked(
            '{"name": "PledgePost Donation NFT #',
            tokenId.toString(),
            '", "description": "',
            tokenData.contentURI,
            '", "image": "',
            imageUrl,
            '", "attributes": [',
            attributes,
            "]}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(metadata)
                )
            );
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Upgradeable, IPledgePostERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function checkOwner(
        address _sender,
        address _author,
        uint256 _articleId
    ) public view returns (bool) {
        for (uint256 i = 0; i < _tokenIdCounter; i++) {
            TokenData memory tokenData = _tokenData[i];
            if (
                tokenData.authorAddress == _author &&
                tokenData.articleId == _articleId &&
                ownerOf(i) == _sender
            ) {
                return true;
            }
        }
        return false;
    }
}
