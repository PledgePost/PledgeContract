// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPledgePostERC721 {
    struct TokenData {
        address minterAddress;
        address authorAddress;
        uint256 articleId;
        string description;
        string imageUrl;
    }

    event Minted(
        address indexed recipient,
        uint256 tokenId,
        address indexed author,
        uint256 indexed articleId,
        uint256 timestamp
    );
    event Burned(address indexed oparator, uint256 indexed tokenId);

    function initialize(address owner, string memory defaultImageUrl) external;

    function setImageUrl(uint256 tokenId, string calldata imageUrl) external;

    function setDefaultImageUrl(string calldata defaultImageUrl) external;

    function mint(
        address minterAddress,
        address authorAddress,
        uint256 articleId,
        string calldata description
    ) external returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function checkOwner(
        address _sender,
        address _author,
        uint256 _articleId
    ) external view returns (bool);
}
