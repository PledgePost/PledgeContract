// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPledgePostERC721 {
    function mint(
        address minterAddress,
        address authorAddress,
        uint256 articleId,
        bytes calldata contentURI
    ) external returns (uint256);

    function checkOwner(
        address _sender,
        address _author,
        uint256 _articleId
    ) external view returns (bool);
}
