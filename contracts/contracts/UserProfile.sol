// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "solady/tokens/ERC721.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {LibString} from "solady/utils/LibString.sol";

/**
 * @title UserProfile
 * @notice NFT-based user profile with dynamic metadata
 * @dev Profile NFT that evolves with user progress (level, XP, achievements)
 */
contract UserProfile is ERC721, Ownable {
    using LibString for uint256;

    struct Profile {
        uint256 level;
        uint256 totalXP;
        uint256[] completedChallenges;
        uint256[] badges;           // Array of badge token IDs (from AchievementBadges)
        uint256 createdAt;
        uint256 lastActive;
        uint256 streak;             // Days active in a row
        uint256 totalSolutions;
        uint256 bestRank;           // Best leaderboard position
    }

    // State
    mapping(uint256 => Profile) public profiles;
    mapping(address => uint256) public addressToTokenId;
    uint256 public nextTokenId = 1;
    
    // Authorized updaters (RewardDistributor, etc.)
    mapping(address => bool) public authorizedUpdaters;
    
    // Level thresholds (XP needed for each level)
    mapping(uint256 => uint256) public levelThresholds;
    
    // Base URI for metadata
    string public baseURI;
    
    // Events
    event ProfileCreated(address indexed user, uint256 indexed tokenId);
    event XPUpdated(uint256 indexed tokenId, uint256 newXP, uint256 newLevel);
    event LevelUp(uint256 indexed tokenId, uint256 newLevel);
    event ChallengeCompleted(uint256 indexed tokenId, uint256 challengeId);
    event BadgeAdded(uint256 indexed tokenId, uint256 badgeId);
    event StreakUpdated(uint256 indexed tokenId, uint256 streak);

    // Errors
    error Unauthorized();
    error ProfileAlreadyExists();
    error ProfileNotFound();
    error InvalidTokenId();

    constructor(string memory _baseURI) {
        _initializeOwner(msg.sender);
        authorizedUpdaters[msg.sender] = true;
        baseURI = _baseURI;
        
        // Initialize level thresholds (exponential growth)
        _initializeLevelThresholds();
    }

    function _initializeLevelThresholds() internal {
        levelThresholds[1] = 0;        // Level 1: 0 XP
        levelThresholds[2] = 100;      // Level 2: 100 XP
        levelThresholds[3] = 250;      // Level 3: 250 XP
        levelThresholds[4] = 500;      // Level 4: 500 XP
        levelThresholds[5] = 1000;     // Level 5: 1000 XP
        levelThresholds[6] = 2000;     // Level 6: 2000 XP
        levelThresholds[7] = 4000;     // Level 7: 4000 XP
        levelThresholds[8] = 8000;     // Level 8: 8000 XP
        levelThresholds[9] = 16000;    // Level 9: 16000 XP
        levelThresholds[10] = 32000;   // Level 10: 32000 XP
    }

    // Modifiers
    modifier onlyAuthorized() {
        if (!authorizedUpdaters[msg.sender] && msg.sender != owner()) {
            revert Unauthorized();
        }
        _;
    }

    // Metadata
    function name() public pure override returns (string memory) {
        return "ChainQuest Profile";
    }

    function symbol() public pure override returns (string memory) {
        return "CQPROFILE";
    }

    /**
     * @notice Mint a new profile (free, once per address)
     */
    function mintProfile() external returns (uint256) {
        if (addressToTokenId[msg.sender] != 0) revert ProfileAlreadyExists();

        uint256 tokenId = nextTokenId++;
        
        profiles[tokenId] = Profile({
            level: 1,
            totalXP: 0,
            completedChallenges: new uint256[](0),
            badges: new uint256[](0),
            createdAt: block.timestamp,
            lastActive: block.timestamp,
            streak: 1,
            totalSolutions: 0,
            bestRank: 0
        });

        addressToTokenId[msg.sender] = tokenId;
        _mint(msg.sender, tokenId);

        emit ProfileCreated(msg.sender, tokenId);
        
        return tokenId;
    }

    /**
     * @notice Update XP and check for level up
     */
    function updateXP(uint256 tokenId, uint256 xpToAdd) external onlyAuthorized {
        Profile storage profile = profiles[tokenId];
        if (profile.createdAt == 0) revert ProfileNotFound();

        uint256 oldLevel = profile.level;
        profile.totalXP += xpToAdd;
        
        // Check for level up
        uint256 newLevel = calculateLevel(profile.totalXP);
        if (newLevel > oldLevel) {
            profile.level = newLevel;
            emit LevelUp(tokenId, newLevel);
        }

        emit XPUpdated(tokenId, profile.totalXP, profile.level);
    }

    /**
     * @notice Add completed challenge
     */
    function addCompletedChallenge(uint256 tokenId, uint256 challengeId) 
        external 
        onlyAuthorized 
    {
        Profile storage profile = profiles[tokenId];
        if (profile.createdAt == 0) revert ProfileNotFound();

        profile.completedChallenges.push(challengeId);
        profile.totalSolutions++;
        profile.lastActive = block.timestamp;

        emit ChallengeCompleted(tokenId, challengeId);
    }

    /**
     * @notice Add badge to profile
     */
    function addBadge(uint256 tokenId, uint256 badgeId) external onlyAuthorized {
        Profile storage profile = profiles[tokenId];
        if (profile.createdAt == 0) revert ProfileNotFound();

        profile.badges.push(badgeId);
        
        emit BadgeAdded(tokenId, badgeId);
    }

    /**
     * @notice Update streak
     */
    function updateStreak(uint256 tokenId) external onlyAuthorized {
        Profile storage profile = profiles[tokenId];
        if (profile.createdAt == 0) revert ProfileNotFound();

        uint256 daysSinceLastActive = (block.timestamp - profile.lastActive) / 1 days;
        
        if (daysSinceLastActive == 1) {
            // Consecutive day - increment streak
            profile.streak++;
        } else if (daysSinceLastActive > 1) {
            // Missed a day - reset streak
            profile.streak = 1;
        }
        // If same day, don't change streak

        profile.lastActive = block.timestamp;
        
        emit StreakUpdated(tokenId, profile.streak);
    }

    /**
     * @notice Update best rank
     */
    function updateBestRank(uint256 tokenId, uint256 rank) external onlyAuthorized {
        Profile storage profile = profiles[tokenId];
        if (profile.createdAt == 0) revert ProfileNotFound();

        if (profile.bestRank == 0 || rank < profile.bestRank) {
            profile.bestRank = rank;
        }
    }

    /**
     * @notice Calculate level based on XP
     */
    function calculateLevel(uint256 xp) public view returns (uint256) {
        for (uint256 level = 10; level >= 1; level--) {
            if (xp >= levelThresholds[level]) {
                return level;
            }
        }
        return 1;
    }

    /**
     * @notice Get profile data
     */
    function getProfile(uint256 tokenId) external view returns (Profile memory) {
        if (profiles[tokenId].createdAt == 0) revert ProfileNotFound();
        return profiles[tokenId];
    }

    /**
     * @notice Get profile by address
     */
    function getProfileByAddress(address user) external view returns (Profile memory) {
        uint256 tokenId = addressToTokenId[user];
        if (tokenId == 0) revert ProfileNotFound();
        return profiles[tokenId];
    }

    /**
     * @notice Get completed challenges
     */
    function getCompletedChallenges(uint256 tokenId) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return profiles[tokenId].completedChallenges;
    }

    /**
     * @notice Get user badges
     */
    function getBadges(uint256 tokenId) external view returns (uint256[] memory) {
        return profiles[tokenId].badges;
    }

    /**
     * @notice Check if user has completed a challenge
     */
    function hasCompletedChallenge(uint256 tokenId, uint256 challengeId) 
        external 
        view 
        returns (bool) 
    {
        uint256[] memory completed = profiles[tokenId].completedChallenges;
        for (uint256 i = 0; i < completed.length; i++) {
            if (completed[i] == challengeId) return true;
        }
        return false;
    }

    // Dynamic metadata
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) revert InvalidTokenId();
        
        Profile memory profile = profiles[tokenId];
        
        // Return dynamic URI based on level
        return string(abi.encodePacked(
            baseURI,
            tokenId.toString(),
            "?level=",
            profile.level.toString(),
            "&xp=",
            profile.totalXP.toString()
        ));
    }

    // Admin functions
    function authorizeUpdater(address updater) external onlyOwner {
        authorizedUpdaters[updater] = true;
    }

    function revokeUpdater(address updater) external onlyOwner {
        authorizedUpdaters[updater] = false;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function setLevelThreshold(uint256 level, uint256 xpRequired) external onlyOwner {
        levelThresholds[level] = xpRequired;
    }

    // Disable transfers (soul-bound NFT)
    function transferFrom(address from, address to, uint256 tokenId) 
        public 
        payable 
        override 
    {
        if (msg.sender != owner()) revert Unauthorized();
        super.transferFrom(from, to, tokenId);
    }
}
