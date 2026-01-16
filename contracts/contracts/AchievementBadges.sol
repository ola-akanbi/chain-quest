// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "solady/tokens/ERC1155.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {LibString} from "solady/utils/LibString.sol";

/**
 * @title AchievementBadges
 * @notice ERC1155 collectible badges for achievements
 * @dev Multi-token standard for various achievement types
 */
contract AchievementBadges is ERC1155, Ownable {
    using LibString for uint256;

    struct BadgeMetadata {
        string name;
        string description;
        string imageURI;
        uint256 totalMinted;
        bool exists;
    }

    // Badge metadata storage
    mapping(uint256 => BadgeMetadata) public badgeTypes;
    uint256 public nextBadgeTypeId = 1;
    
    // Authorized minters
    mapping(address => bool) public authorizedMinters;
    
    // Track who earned which badges
    mapping(address => mapping(uint256 => bool)) public hasEarned;

    // Base URI for metadata
    string public baseURI;

    // Events
    event BadgeTypeCreated(uint256 indexed badgeId, string name);
    event BadgeMinted(address indexed recipient, uint256 indexed badgeId);
    event MinterAuthorized(address indexed minter);
    event MinterRevoked(address indexed minter);

    // Errors
    error Unauthorized();
    error BadgeNotFound();
    error AlreadyEarned();

    constructor(string memory _baseURI) {
        _initializeOwner(msg.sender);
        authorizedMinters[msg.sender] = true;
        baseURI = _baseURI;
        
        // Create initial badge types
        _createInitialBadges();
    }

    modifier onlyAuthorizedMinter() {
        if (!authorizedMinters[msg.sender] && msg.sender != owner()) {
            revert Unauthorized();
        }
        _;
    }

    function _createInitialBadges() internal {
        // Milestone badges
        createBadgeType(
            "First Blood",
            "Complete your first challenge",
            "ipfs://QmFirstBlood"
        );
        
        createBadgeType(
            "Rising Star",
            "Reach Level 5",
            "ipfs://QmRisingStar"
        );
        
        createBadgeType(
            "Elite Coder",
            "Reach Level 10",
            "ipfs://QmEliteCoder"
        );

        // Speed badges
        createBadgeType(
            "Speed Demon",
            "Solve a challenge in record time",
            "ipfs://QmSpeedDemon"
        );
        
        createBadgeType(
            "Lightning Fast",
            "Solve 3 challenges in under 10 minutes each",
            "ipfs://QmLightningFast"
        );

        // Streak badges
        createBadgeType(
            "Consistent",
            "7-day activity streak",
            "ipfs://QmConsistent"
        );
        
        createBadgeType(
            "Streak Master",
            "30-day activity streak",
            "ipfs://QmStreakMaster"
        );

        // Category badges
        createBadgeType(
            "DeFi Master",
            "Complete all DeFi challenges",
            "ipfs://QmDeFiMaster"
        );
        
        createBadgeType(
            "NFT Expert",
            "Complete all NFT challenges",
            "ipfs://QmNFTExpert"
        );
        
        createBadgeType(
            "Security Specialist",
            "Complete all Security challenges",
            "ipfs://QmSecuritySpecialist"
        );

        // Special badges
        createBadgeType(
            "Bug Hunter",
            "Found a bug in a challenge",
            "ipfs://QmBugHunter"
        );
        
        createBadgeType(
            "Gas Optimizer",
            "Achieved top 10% gas efficiency",
            "ipfs://QmGasOptimizer"
        );
        
        createBadgeType(
            "Community Helper",
            "Helped 10+ users with hints/reviews",
            "ipfs://QmCommunityHelper"
        );
        
        createBadgeType(
            "Perfect Score",
            "Achieved 100% on all tests",
            "ipfs://QmPerfectScore"
        );
        
        createBadgeType(
            "Early Adopter",
            "One of the first 100 users",
            "ipfs://QmEarlyAdopter"
        );
    }

    /**
     * @notice Create a new badge type
     */
    function createBadgeType(
        string memory name,
        string memory description,
        string memory imageURI
    ) public onlyOwner returns (uint256) {
        uint256 badgeId = nextBadgeTypeId++;
        
        badgeTypes[badgeId] = BadgeMetadata({
            name: name,
            description: description,
            imageURI: imageURI,
            totalMinted: 0,
            exists: true
        });

        emit BadgeTypeCreated(badgeId, name);
        
        return badgeId;
    }

    /**
     * @notice Mint a badge to a user
     */
    function mintBadge(address recipient, uint256 badgeId) 
        external 
        onlyAuthorizedMinter 
    {
        if (!badgeTypes[badgeId].exists) revert BadgeNotFound();
        if (hasEarned[recipient][badgeId]) revert AlreadyEarned();

        hasEarned[recipient][badgeId] = true;
        badgeTypes[badgeId].totalMinted++;
        
        _mint(recipient, badgeId, 1, "");

        emit BadgeMinted(recipient, badgeId);
    }

    /**
     * @notice Batch mint multiple badges
     */
    function mintBadgeBatch(
        address recipient,
        uint256[] calldata badgeIds
    ) external onlyAuthorizedMinter {
        uint256[] memory amounts = new uint256[](badgeIds.length);
        
        for (uint256 i = 0; i < badgeIds.length; i++) {
            if (!badgeTypes[badgeIds[i]].exists) revert BadgeNotFound();
            if (hasEarned[recipient][badgeIds[i]]) revert AlreadyEarned();
            
            hasEarned[recipient][badgeIds[i]] = true;
            badgeTypes[badgeIds[i]].totalMinted++;
            amounts[i] = 1;
        }

        _batchMint(recipient, badgeIds, amounts, "");
    }

    /**
     * @notice Get badge metadata
     */
    function getBadgeMetadata(uint256 badgeId) 
        external 
        view 
        returns (BadgeMetadata memory) 
    {
        if (!badgeTypes[badgeId].exists) revert BadgeNotFound();
        return badgeTypes[badgeId];
    }

    /**
     * @notice Check if user has earned a badge
     */
    function hasBadge(address user, uint256 badgeId) 
        external 
        view 
        returns (bool) 
    {
        return hasEarned[user][badgeId];
    }

    /**
     * @notice Get all badges owned by user
     */
    function getUserBadges(address user) 
        external 
        view 
        returns (uint256[] memory) 
    {
        uint256 count = 0;
        
        // Count badges
        for (uint256 i = 1; i < nextBadgeTypeId; i++) {
            if (hasEarned[user][i]) count++;
        }

        // Populate array
        uint256[] memory badges = new uint256[](count);
        uint256 index = 0;
        
        for (uint256 i = 1; i < nextBadgeTypeId; i++) {
            if (hasEarned[user][i]) {
                badges[index] = i;
                index++;
            }
        }

        return badges;
    }

    /**
     * @notice URI for badge metadata
     */
    function uri(uint256 badgeId) public view override returns (string memory) {
        if (!badgeTypes[badgeId].exists) revert BadgeNotFound();
        
        return string(abi.encodePacked(
            baseURI,
            badgeId.toString(),
            ".json"
        ));
    }

    // Admin functions
    function authorizeMinter(address minter) external onlyOwner {
        authorizedMinters[minter] = true;
        emit MinterAuthorized(minter);
    }

    function revokeMinter(address minter) external onlyOwner {
        authorizedMinters[minter] = false;
        emit MinterRevoked(minter);
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function updateBadgeMetadata(
        uint256 badgeId,
        string calldata name,
        string calldata description,
        string calldata imageURI
    ) external onlyOwner {
        if (!badgeTypes[badgeId].exists) revert BadgeNotFound();
        
        BadgeMetadata storage badge = badgeTypes[badgeId];
        badge.name = name;
        badge.description = description;
        badge.imageURI = imageURI;
    }

    // Disable transfers (soul-bound badges)
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public override {
        if (msg.sender != owner()) revert Unauthorized();
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public override {
        if (msg.sender != owner()) revert Unauthorized();
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}
