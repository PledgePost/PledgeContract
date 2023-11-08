// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IPledgePostERC721 {
    function setImageUrl(uint256 tokenId, string calldata imageUrl) external;

    function setDefaultImageUrl(string calldata defaultImageUrl) external;

    function mint(
        address minterAddress,
        address authorAddress,
        uint256 articleId,
        string calldata description
    ) external returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function burn(uint256[] calldata tokenId) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function getImageUrl(uint256 tokenId) external view returns (string memory);

    function checkOwner(
        address _sender,
        address _author,
        uint256 _articleId
    ) external view returns (bool);
}
