// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {IPledgePostERC721} from "./interface/IPledgePostERC721.sol";

contract PledgePostERC721 is ERC721, Ownable {
    uint256 private _nextTokenId;
    struct TokenData {
        address minterAddress;
        address authorAddress;
        uint256 articleId;
        bytes contentURI;
    }
    mapping(uint256 => TokenData) private _tokenData;

    constructor(
        address initialOwner
    ) ERC721("MyToken", "MTK") Ownable(initialOwner) {}

    function safeMint(
        address minterAddress,
        address authorAddress,
        uint256 articleId,
        bytes calldata contentURI
    ) external onlyOwner {
        require(minterAddress != address(0), "Minter address is zero");
        require(authorAddress != address(0), "Author address is zero");
        require(contentURI.length > 0, "ContentURI is empty");

        uint256 tokenId = _nextTokenId++;
        _safeMint(minterAddress, tokenId);
        _tokenData[tokenId] = TokenData(
            minterAddress,
            authorAddress,
            articleId,
            contentURI
        );
    }

    function checkOwner(
        address _sender,
        address _author,
        uint256 _articleId
    ) public view returns (bool) {
        for (uint256 i = 0; i < _nextTokenId; i++) {
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
