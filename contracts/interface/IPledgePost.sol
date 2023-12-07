// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPledgePost {
    struct Article {
        uint256 id;
        address payable author;
        string content; // IPFS hash
        uint256 donationsReceived;
    }
    struct Round {
        uint256 id;
        address owner;
        bytes name;
        bytes description;
        address payable poolAddress;
        uint256 poolAmount;
        uint256 startDate;
        uint256 endDate;
        bool isActive;
    }
    enum ApplicationStatus {
        Pending,
        Accepted,
        Denied
    }
    event ArticlePosted(
        address indexed author,
        string content,
        uint256 articleId
    );
    event ArticleDonated(
        address indexed author,
        address indexed from,
        uint256 articleId,
        uint256 amount
    );
    event RoundCreated(
        address indexed owner,
        address ipoolAddress,
        uint256 roundId,
        bytes name,
        bytes description,
        uint256 startDate,
        uint256 endDate
    );
    event RoundApplied(
        address indexed author,
        uint256 articleId,
        uint256 roundId
    );
    event Allocated(
        uint256 indexed roundId,
        address recipient,
        uint256 articleId,
        uint256 amount
    );

    function initialize(address _owner, uint256 _MINIMUM_AMOUNT) external;

    function addAdmin(address _admin) external;

    function checkAdminRole(address _admin) external view returns (bool);

    function removeAdmin(address _admin) external;

    function postArticle(string calldata _content) external;

    function updateArticle(
        uint256 _articleId,
        string calldata _content
    ) external;

    function donateToArticle(
        address payable _author,
        uint256 _articleId
    ) external payable;

    function applyForRound(uint256 _roundId, uint256 _articleId) external;

    function acceptApplication(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) external;

    function denyApplication(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) external;

    function createRound(
        string calldata _name,
        string calldata _description,
        uint256 _startDate,
        uint256 _endDate
    ) external;

    function activateRound(uint256 _roundId) external;

    function deactivateRound(uint256 _roundId) external;

    function changeMinimumAmount(uint256 _amount) external;

    function Allocate(uint256 _roundId) external;

    function deposit(uint256 _roundId) external payable returns (bool);

    function getTotalSquareSqrtSum(
        uint256 _roundId
    ) external view returns (uint256);

    function getMatchingAmount(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) external view returns (uint256);

    function getAllocation(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) external view returns (uint256);

    function getDonatedAmount(
        address _author,
        uint256 _articleId
    ) external view returns (uint256);

    function getSquareRoot(uint256 x) external pure returns (uint256);

    function getAppliedArticle(
        uint256 _roundId,
        uint256 _index
    ) external view returns (Article memory);

    function getAuthorArticle(
        address _author,
        uint256 _articleId
    ) external view returns (Article memory);

    function getAllAuthorArticle(
        address _author
    ) external view returns (Article[] memory);

    function getAppliedRound(
        address _author,
        uint256 _articleId
    ) external view returns (Round memory);

    function getRoundLength() external view returns (uint256);

    function getRound(uint256 _roundId) external view returns (Round memory);

    function getSqrtSumRoundDonation(
        address _author,
        uint256 _articleId,
        uint256 _roundId
    ) external view returns (uint256);

    function getApplicationStatus(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) external view returns (ApplicationStatus);

    function checkOwner(
        address _sender,
        address _author,
        uint256 _articleId
    ) external view returns (bool);
}
