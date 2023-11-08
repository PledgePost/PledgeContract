// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import {IPledgePostERC721} from "./interface/IPledgePostERC721.sol";

contract PledgePostERC721 is
    ERC721,
    ERC721Enumerable,
    Ownable,
    IPledgePostERC721
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIdCounter;
    address private _owner;

    struct TokenData {
        address minterAddress;
        address authorAddress;
        uint256 articleId;
        string description;
        string imageUrl;
    }

    mapping(uint256 => TokenData) private _tokenData;
    string private _defaultImageUrl;
    event Minted(
        address indexed recipient,
        uint256 tokenId,
        address indexed author,
        uint256 indexed articleId,
        uint256 timestamp
    );
    event Burned(address indexed oparator, uint256 indexed tokenId);

    constructor(
        address owner,
        string memory defaultImageUrl
    ) ERC721("PledgePost Donation NFT", "PLPDNFT") {
        _defaultImageUrl = defaultImageUrl;
        _owner = owner;
    }

    function setImageUrl(
        uint256 tokenId,
        string memory imageUrl
    ) external onlyOwner {
        require(_exists(tokenId), "URI query for nonexistent token");
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
        string memory description
    ) external onlyOwner returns (uint256) {
        require(minterAddress != address(0), "Minter address is zero");
        require(authorAddress != address(0), "Author address is zero");
        require(bytes(description).length > 0, "Description is empty");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(minterAddress, tokenId);

        TokenData storage tokenData = _tokenData[tokenId];
        tokenData.minterAddress = minterAddress;
        tokenData.description = description;
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
    ) public view override(ERC721, IPledgePostERC721) returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

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
            tokenData.description,
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        require(
            from == address(0) || to == address(0),
            "Err: This token is not transferable"
        );
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function burn(uint256[] memory tokenId) external {
        for (uint256 i = 0; i < tokenId.length; i++) {
            _burn(tokenId[i]);
            emit Burned(msg.sender, tokenId[i]);
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, ERC721Enumerable, IPledgePostERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function getImageUrl(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");
        TokenData memory tokenData = _tokenData[tokenId];
        return
            bytes(tokenData.imageUrl).length > 0
                ? tokenData.imageUrl
                : _defaultImageUrl;
    }

    function checkOwner(
        address _sender,
        address _author,
        uint256 _articleId
    ) public view returns (bool) {
        uint256 totalSupply = totalSupply();
        for (uint256 i = 0; i < totalSupply; i++) {
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
