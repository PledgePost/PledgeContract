// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

// internal contracts
import {PoolContract} from "./PoolContract.sol";
import {PledgePostERC721} from "./PledgePostERC721.sol";
import {Sqrt} from "./libraries/Sqrt.sol";

// interfaces
import "./interface/IPledgePost.sol";
import "./interface/IPoolContract.sol";
import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";

contract PledgePost is
    IPledgePost,
    Initializable,
    AccessControlUpgradeable,
    OwnableUpgradeable
{
    bytes32 ADMIN_ROLE;
    uint256 private MINIMUM_AMOUNT;
    uint256 roundLength;

    PledgePostERC721 private nft;
    IEAS public eas;

    // author => articles
    // track articles by author
    mapping(address => Article[]) private authorArticles;
    // author => totalDonations
    // track total donations by author
    mapping(address => uint256) private authorTotalDonations;
    // author => articleId => donators
    // track donators by article
    mapping(address => mapping(uint256 => address[])) private articleDonators;
    // Round.id => Article[]
    // track articles by round
    mapping(uint256 => Article[]) private roundArticles;
    // author => Article.id => Round
    // track round that article has applied for
    mapping(address => mapping(uint256 => Round))
        private authorToArticleIdToRound;
    // author => Article.id => Round.id => ApplicationStatus
    // track application status for each round
    mapping(address => mapping(uint256 => mapping(uint256 => ApplicationStatus)))
        private applicationStatusForRound;

    // author => Article.id => Round.id => uint256
    // sum of sqrt of donations for each article
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        private SqrtSumRoundDonation;

    // round.id => author => article.id => amount
    // matching amount for each article
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private matchingAmounts;

    // array of rounds
    Round[] private rounds;

    /// @dev see { openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol }
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // - initialize: This function initializes the contract with the owner's address and sets up the admin role.
    // It also sets the minimum donation amount and initializes the NFT contract.
    function initialize(address _owner /*, IEAS _eas */) external initializer {
        // initialize owner of contract
        __Ownable_init(_owner);
        // initialize admin role
        __AccessControl_init();

        // initialize eas
        // eas = _eas;
        ADMIN_ROLE = keccak256("ADMIN_ROLE");
        _grantRole(ADMIN_ROLE, _owner);

        // initialize variables
        MINIMUM_AMOUNT = 0.0005 ether;
        roundLength = 0;

        nft = new PledgePostERC721(address(this));
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    // - changeMinimumAmount: This function allows the owner to change the minimum donation amount.
    function changeMinimumAmount(uint256 _amount) external onlyOwner {
        MINIMUM_AMOUNT = _amount;
    }

    function addAdmin(address _admin) external onlyOwner {
        _grantRole(ADMIN_ROLE, _admin);
    }

    function checkAdminRole(address _admin) external view returns (bool) {
        return hasRole(ADMIN_ROLE, _admin);
    }

    function removeAdmin(address _admin) external onlyOwner {
        revokeRole(ADMIN_ROLE, _admin);
    }

    // - postArticle: This function allows a user to post an article.
    function postArticle(string calldata _content) external {
        require(bytes(_content).length > 0, "Content cannot be empty");
        uint articleId = authorArticles[msg.sender].length;
        Article memory newArticle = Article({
            id: articleId,
            author: payable(msg.sender),
            content: _content,
            donationsReceived: 0
        });

        authorArticles[msg.sender].push(newArticle);

        emit ArticlePosted(msg.sender, _content, articleId);
    }

    // - updateArticle: This function allows the author of an article to update its contentId.
    function updateArticle(
        uint256 _articleId,
        string calldata _content
    ) external {
        require(
            msg.sender == authorArticles[msg.sender][_articleId].author,
            "Only author can update article"
        );
        require(bytes(_content).length > 0, "Content cannot be empty");
        require(
            _articleId < authorArticles[msg.sender].length,
            "Article does not exist"
        );
        Article storage article = authorArticles[msg.sender][_articleId];
        article.content = _content;
    }

    // - donateToArticle: This function allows a user to donate to an article.
    function donateToArticle(
        address payable _author,
        uint256 _articleId
    ) external payable {
        require(msg.sender != _author, "author cannot donate to self");
        require(
            msg.value > MINIMUM_AMOUNT,
            "donation must be greater than minimum amount"
        );
        require(
            _articleId < authorArticles[_author].length,
            "Article does not exist"
        );
        Article storage article = authorArticles[_author][_articleId];
        // Transfer tokens from the sender to the author

        (bool sent, ) = _author.call{value: msg.value}("");
        require(sent, "Failed to donate Ether");

        // Add donator to the list
        articleDonators[_author][_articleId].push(msg.sender);
        // Update donation amounts
        article.donationsReceived += msg.value;
        authorTotalDonations[_author] += msg.value;

        // check if author has applied for round and accepted
        // check if round is active
        // if yes, add amount to sum of sqrt of donations
        Round storage round = authorToArticleIdToRound[_author][_articleId];
        if (
            round.id >= 0 &&
            round.isActive &&
            applicationStatusForRound[_author][_articleId][round.id] ==
            ApplicationStatus.Accepted
        ) {
            SqrtSumRoundDonation[_author][_articleId][round.id] += Sqrt.sqrt(
                msg.value
            );
        }
        emit ArticleDonated(_author, msg.sender, _articleId, msg.value);
        nft.safeMint(msg.sender, _author, _articleId, article.content);
    }

    // - applyForRound: This function allows an author to apply their article for a funding round.
    function applyForRound(uint256 _roundId, uint256 _articleId) external {
        Article storage article = authorArticles[msg.sender][_articleId];
        require(
            msg.sender == article.author,
            "Only author can apply for round"
        );
        require(_roundId <= roundLength, "Round does not exist");
        require(_roundId > 0, "RoundId 0 does not exist");
        Round storage round = rounds[_roundId - 1];
        require(round.isActive, "Round is not active");
        require(round.endDate > block.timestamp, "Round has ended");
        require(
            _articleId < authorArticles[msg.sender].length,
            "Article does not exist"
        );

        authorToArticleIdToRound[msg.sender][_articleId] = round;
        roundArticles[_roundId].push(article);
        applicationStatusForRound[msg.sender][_articleId][
            _roundId
        ] = ApplicationStatus.Pending;

        emit RoundApplied(msg.sender, _articleId, _roundId);
    }

    // TODO: control status when donated
    function acceptApplication(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) external onlyAdmin {
        require(
            applicationStatusForRound[_author][_articleId][_roundId] ==
                ApplicationStatus.Pending,
            "Application status is not Pending"
        );
        applicationStatusForRound[_author][_articleId][
            _roundId
        ] = ApplicationStatus.Accepted;
    }

    function denyApplication(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) external onlyAdmin {
        require(
            applicationStatusForRound[_author][_articleId][_roundId] ==
                ApplicationStatus.Pending,
            "Application status is not Pending"
        );
        applicationStatusForRound[_author][_articleId][
            _roundId
        ] = ApplicationStatus.Denied;
    }

    function _createPool(
        string calldata _name,
        uint256 _startDate,
        uint256 _endDate
    ) internal returns (address payable poolAddress) {
        bytes memory bytecode = type(PoolContract).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_name, _startDate, _endDate));
        assembly {
            poolAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        return poolAddress;
    }

    // TODO: add matching cap
    // - createRound: This function allows an admin to create a new funding round.
    function createRound(
        string calldata _name,
        string calldata _description,
        uint256 _startDate,
        uint256 _endDate
    ) external onlyAdmin {
        // TODO: fix date validation
        require(_startDate < _endDate, "Start date must be before end date");
        // require(
        //     _startDate > block.timestamp,
        //     "Start date must be in the future"
        // );
        require(_endDate > block.timestamp, "End date must be in the future");

        address payable pool = _createPool(_name, _startDate, _endDate);
        Round memory newRound = Round({
            id: roundLength + 1,
            owner: msg.sender, // TODO: change round owner
            name: bytes(_name),
            description: bytes(_description),
            poolAddress: pool,
            poolAmount: 0,
            startDate: _startDate,
            endDate: _endDate,
            isActive: false
        });
        rounds.push(newRound);
        emit RoundCreated(
            msg.sender,
            pool,
            roundLength + 1,
            bytes(_name),
            _startDate,
            _endDate
        );
        roundLength++;
    }

    function activateRound(uint256 _roundId) external onlyAdmin {
        require(_roundId <= roundLength, "Round does not exist");
        require(_roundId > 0, "RoundId 0 does not exist");
        Round storage round = rounds[_roundId - 1];
        require(!round.isActive, "Round is already active");
        require(round.endDate > block.timestamp, "Round has ended");
        round.isActive = true;
    }

    function deactivateRound(uint256 _roundId) external onlyAdmin {
        require(_roundId <= roundLength, "Round does not exist");
        require(_roundId > 0, "RoundId 0 does not exist");
        Round storage round = rounds[_roundId - 1];
        require(round.isActive, "Round is not active");
        round.isActive = false;
    }

    // deposit should be done via deposit function
    function deposit(uint256 _roundId) external payable returns (bool) {
        require(_roundId <= roundLength, "Round does not exist");
        require(_roundId > 0, "RoundId 0 does not exist");
        require(
            address(msg.sender).balance >= msg.value,
            "Not enough balance to deposit"
        );
        Round storage round = rounds[_roundId - 1];
        address pool = address(IPoolContract(round.poolAddress));
        (bool sent, ) = payable(pool).call{value: msg.value}("");
        require(sent, "Failed to deposit Ether");
        round.poolAmount += msg.value;
        return sent;
    }

    // get sum of sqrt x
    // get squared sum of sqrt x
    // calculate matching pool * suquare sum of sqrt donation / total squared sum of donations
    function Allocate(uint256 _roundId) external onlyAdmin {
        require(_roundId <= roundLength, "Round does not exist");
        require(_roundId > 0, "RoundId 0 does not exist");

        Round memory round = getRound(_roundId);
        // calculate matching for each article
        require(roundArticles[_roundId].length > 0, "No articles in round");
        for (uint256 i = 0; i < roundArticles[_roundId].length; i++) {
            Article storage article = roundArticles[_roundId][i];
            uint256 matching = getMatchingAmount(
                _roundId,
                article.author,
                article.id
            );
            matchingAmounts[_roundId][article.author][article.id] = matching;
            // transfer matching to author address if matching > 0
            if (matching > 0) {
                bool transferSuccessful = IPoolContract(round.poolAddress)
                    .poolTransfer(article.author, matching);
                require(transferSuccessful, "Allocation transfer failed");
                emit Allocated(_roundId, article.author, article.id, matching);
            }
        }
    }

    // - getMatchingAmount: This function calculates the matching amount for an article in a round.
    function getMatchingAmount(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) public view returns (uint256) {
        uint256 totalSquareSqrtSum = getTotalSquareSqrtSum(_roundId);
        uint256 suquareSqrtSum = getSqrtSumRoundDonation(
            _author,
            _articleId,
            _roundId
        ) ** 2;
        Round storage round = rounds[_roundId - 1];
        uint256 matching = (round.poolAmount * suquareSqrtSum) /
            totalSquareSqrtSum;
        return matching;
    }

    // - getTotalSquareSqrtSum: This function calculates the total square root sum of donations for all articles in a round.
    function getTotalSquareSqrtSum(
        uint256 _roundId
    ) public view returns (uint256) {
        uint256 totalSquareSqrtSum = 0;
        for (uint256 i = 0; i < roundArticles[_roundId].length; i++) {
            require(roundArticles[_roundId].length > 0, "No articles in round");
            Article storage article = roundArticles[_roundId][i];
            uint256 sqrtSum = getSqrtSumRoundDonation(
                article.author,
                article.id,
                _roundId
            );
            totalSquareSqrtSum += sqrtSum ** 2;
        }
        return totalSquareSqrtSum;
    }

    // - getAllocation: This function returns the allocation for an article in a round.
    // this function is only available after the round has ended
    function getAllocation(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) external view returns (uint256) {
        return matchingAmounts[_roundId][_author][_articleId];
    }

    function getSquareRoot(uint256 x) external pure returns (uint256) {
        return Sqrt.sqrt(x);
    }

    function getAppliedArticle(
        uint256 _roundId,
        uint256 _index
    ) external view returns (Article memory) {
        require(roundArticles[_roundId].length > 0, "No articles in round");
        return roundArticles[_roundId][_index];
    }

    // - getDonatedAmount: This function returns the total amount donated to an article.
    function getDonatedAmount(
        address _author,
        uint256 _articleId
    ) public view returns (uint256) {
        require(
            _articleId < authorArticles[_author].length,
            "Article does not exist"
        );
        return authorArticles[_author][_articleId].donationsReceived;
    }

    // - getArticleDonators: This function returns the list of donators for an article.
    function getArticleDonators(
        address _author,
        uint256 _articleId
    ) external view returns (address[] memory) {
        return articleDonators[_author][_articleId];
    }

    // - getAuthorArticle: This function returns an article by a given author.
    function getAuthorArticle(
        address _author,
        uint256 _articleId
    ) external view returns (Article memory) {
        return authorArticles[_author][_articleId];
    }

    // - getAllAuthorArticle: This function returns all articles by a given author.
    function getAllAuthorArticle(
        address _author
    ) external view returns (Article[] memory) {
        return authorArticles[_author];
    }

    function getAppliedRound(
        address _author,
        uint256 _articleId
    ) external view returns (Round memory) {
        return authorToArticleIdToRound[_author][_articleId];
    }

    function getRoundLength() external view returns (uint256) {
        return roundLength;
    }

    // - getRound: This function returns a round by its ID.
    function getRound(uint256 _roundId) public view returns (Round memory) {
        return rounds[_roundId - 1];
    }

    // -getSqrtSumRoundDonation : This function returns the sum of sqrt of donations for each article in a round.
    function getSqrtSumRoundDonation(
        address _author,
        uint256 _articleId,
        uint256 _roundId
    ) public view returns (uint256) {
        return SqrtSumRoundDonation[_author][_articleId][_roundId];
    }

    function getApplicationStatus(
        uint256 _roundId,
        address _author,
        uint256 _articleId
    ) external view returns (ApplicationStatus) {
        return applicationStatusForRound[_author][_articleId][_roundId];
    }

    // - checkOwner: This function checks if a given address has donated to a given article.
    // donation is represented by an NFT
    function checkOwner(
        address _sender,
        address _author,
        uint256 _articleId
    ) public view returns (bool) {
        return nft.checkOwner(_sender, _author, _articleId);
    }

    // - checkScore: This function checks if a given address has a score greater than or equal to a given score.
    function checkScore(
        bytes32 uid, // uid of the attestation
        address recipient,
        uint256 score
    ) public view returns (bool) {
        uint256 attestationScore = getPassportAttestation(uid, recipient);
        return attestationScore >= score;
    }

    // - getPassportAttestation: This function returns the score of an attestation.
    function getPassportAttestation(
        bytes32 uid, // uid of the attestation
        address recipient //
    ) public view returns (uint256 score) {
        // check if attestation exists
        require(eas.isAttestationValid(uid), "Attestation is not valid");

        Attestation memory attestation = eas.getAttestation(uid);
        // check if the address is the recipient of the attestation
        require(
            attestation.recipient == recipient,
            "Invalid recipient of attestation"
        );
        bytes memory encodedData = attestation.data;
        score = decodeScore(encodedData);

        // check if score is valid on core contract
        // just return score
        return score;
    }

    function decodeScore(
        bytes memory encodedData
    ) internal pure returns (uint256 decodedScore) {
        uint256 score;
        uint32 scorer_id;
        uint8 score_decimals;

        (score, scorer_id, score_decimals) = abi.decode(
            encodedData,
            (uint256, uint32, uint8)
        );

        decodedScore = score / 10 ** 18;
        return decodedScore;
    }
}
