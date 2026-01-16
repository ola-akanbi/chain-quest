// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "solady/auth/Ownable.sol";

/**
 * @title ChallengeRegistry
 * @notice Central registry for all programming challenges on the platform
 * @dev Stores challenge metadata, manages categories and difficulty levels
 */
contract ChallengeRegistry is Ownable {
    // Enums
    enum Difficulty {
        BEGINNER,    // 1 - Simple storage, basic tokens
        EASY,        // 2 - Basic DeFi concepts
        MEDIUM,      // 3 - DEX, NFT marketplace
        HARD,        // 4 - Flash loans, governance
        EXPERT       // 5 - Advanced protocols, ZK proofs
    }

    enum Category {
        DEFI,
        NFT,
        SECURITY,
        GOVERNANCE,
        GAMEFI,
        INFRASTRUCTURE,
        ADVANCED_PATTERNS,
        GAS_OPTIMIZATION
    }

    // Structs
    struct Challenge {
        uint256 id;
        string title;
        string description;
        string ipfsHash;           // Full challenge details on IPFS
        Difficulty difficulty;
        Category category;
        uint256 basePoints;        // Base points for completion
        uint256 requiredLevel;     // Minimum user level required
        bytes32 testCriteriaHash;  // Hash of test requirements
        address author;
        uint256 createdAt;
        bool isActive;
    }

    // State
    mapping(uint256 => Challenge) public challenges;
    mapping(address => bool) public authorizedCreators;
    uint256 public totalChallenges;
    
    // Indexes for filtering
    mapping(Difficulty => uint256[]) private challengesByDifficulty;
    mapping(Category => uint256[]) private challengesByCategory;

    // Events
    event ChallengeCreated(
        uint256 indexed challengeId,
        string title,
        Difficulty difficulty,
        Category category,
        address indexed author
    );
    
    event ChallengeUpdated(uint256 indexed challengeId);
    event ChallengeStatusChanged(uint256 indexed challengeId, bool isActive);
    event CreatorAuthorized(address indexed creator);
    event CreatorRevoked(address indexed creator);

    // Errors
    error Unauthorized();
    error ChallengeNotFound();
    error InvalidChallenge();

    constructor() {
        _initializeOwner(msg.sender);
        authorizedCreators[msg.sender] = true;
    }

    // Modifiers
    modifier onlyAuthorized() {
        if (!authorizedCreators[msg.sender] && msg.sender != owner()) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @notice Create a new challenge
     * @param title Challenge title
     * @param description Short description
     * @param ipfsHash IPFS hash containing full details
     * @param difficulty Difficulty level
     * @param category Challenge category
     * @param basePoints Points awarded for completion
     * @param requiredLevel Minimum user level required
     * @param testCriteriaHash Hash of test requirements
     */
    function createChallenge(
        string calldata title,
        string calldata description,
        string calldata ipfsHash,
        Difficulty difficulty,
        Category category,
        uint256 basePoints,
        uint256 requiredLevel,
        bytes32 testCriteriaHash
    ) external onlyAuthorized returns (uint256) {
        if (bytes(title).length == 0 || basePoints == 0) {
            revert InvalidChallenge();
        }

        uint256 challengeId = ++totalChallenges;

        challenges[challengeId] = Challenge({
            id: challengeId,
            title: title,
            description: description,
            ipfsHash: ipfsHash,
            difficulty: difficulty,
            category: category,
            basePoints: basePoints,
            requiredLevel: requiredLevel,
            testCriteriaHash: testCriteriaHash,
            author: msg.sender,
            createdAt: block.timestamp,
            isActive: true
        });

        // Add to indexes
        challengesByDifficulty[difficulty].push(challengeId);
        challengesByCategory[category].push(challengeId);

        emit ChallengeCreated(challengeId, title, difficulty, category, msg.sender);

        return challengeId;
    }

    /**
     * @notice Update an existing challenge
     */
    function updateChallenge(
        uint256 challengeId,
        string calldata description,
        string calldata ipfsHash,
        uint256 basePoints,
        bytes32 testCriteriaHash
    ) external onlyAuthorized {
        Challenge storage challenge = challenges[challengeId];
        if (challenge.id == 0) revert ChallengeNotFound();

        challenge.description = description;
        challenge.ipfsHash = ipfsHash;
        challenge.basePoints = basePoints;
        challenge.testCriteriaHash = testCriteriaHash;

        emit ChallengeUpdated(challengeId);
    }

    /**
     * @notice Toggle challenge active status
     */
    function setChallengeStatus(uint256 challengeId, bool isActive) external onlyOwner {
        Challenge storage challenge = challenges[challengeId];
        if (challenge.id == 0) revert ChallengeNotFound();

        challenge.isActive = isActive;
        emit ChallengeStatusChanged(challengeId, isActive);
    }

    /**
     * @notice Authorize a new challenge creator
     */
    function authorizeCreator(address creator) external onlyOwner {
        authorizedCreators[creator] = true;
        emit CreatorAuthorized(creator);
    }

    /**
     * @notice Revoke creator authorization
     */
    function revokeCreator(address creator) external onlyOwner {
        authorizedCreators[creator] = false;
        emit CreatorRevoked(creator);
    }

    // View functions

    /**
     * @notice Get challenge details
     */
    function getChallenge(uint256 challengeId) external view returns (Challenge memory) {
        Challenge memory challenge = challenges[challengeId];
        if (challenge.id == 0) revert ChallengeNotFound();
        return challenge;
    }

    /**
     * @notice Get challenges by difficulty
     */
    function getChallengesByDifficulty(Difficulty difficulty) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return challengesByDifficulty[difficulty];
    }

    /**
     * @notice Get challenges by category
     */
    function getChallengesByCategory(Category category) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return challengesByCategory[category];
    }

    /**
     * @notice Get all active challenges (paginated)
     */
    function getActiveChallenges(uint256 offset, uint256 limit) 
        external 
        view 
        returns (Challenge[] memory) 
    {
        uint256 activeCount = 0;
        
        // Count active challenges
        for (uint256 i = 1; i <= totalChallenges; i++) {
            if (challenges[i].isActive) activeCount++;
        }

        // Calculate actual return size
        uint256 end = offset + limit;
        if (end > activeCount) end = activeCount;
        uint256 size = end > offset ? end - offset : 0;

        Challenge[] memory result = new Challenge[](size);
        uint256 currentIndex = 0;
        uint256 resultIndex = 0;

        // Populate result
        for (uint256 i = 1; i <= totalChallenges && resultIndex < size; i++) {
            if (challenges[i].isActive) {
                if (currentIndex >= offset) {
                    result[resultIndex] = challenges[i];
                    resultIndex++;
                }
                currentIndex++;
            }
        }

        return result;
    }
}
