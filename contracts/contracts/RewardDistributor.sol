// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "solady/auth/Ownable.sol";

/**
 * @title RewardDistributor
 * @notice Distributes rewards (XP, badges, tokens) for completed challenges
 * @dev Central hub for reward logic and distribution
 */
contract RewardDistributor is Ownable {
    // Contract interfaces
    address public experienceToken;
    address public achievementBadges;
    address public userProfile;
    address public challengeRegistry;
    address public solutionSubmission;

    // Badge IDs
    uint256 public constant BADGE_FIRST_BLOOD = 1;
    uint256 public constant BADGE_RISING_STAR = 2;
    uint256 public constant BADGE_ELITE_CODER = 3;
    uint256 public constant BADGE_SPEED_DEMON = 4;
    uint256 public constant BADGE_LIGHTNING_FAST = 5;
    uint256 public constant BADGE_CONSISTENT = 6;
    uint256 public constant BADGE_STREAK_MASTER = 7;
    uint256 public constant BADGE_GAS_OPTIMIZER = 12;
    uint256 public constant BADGE_PERFECT_SCORE = 14;

    // Reward multipliers (basis points: 10000 = 1x)
    mapping(uint256 => uint256) public difficultyMultipliers;
    uint256 public speedBonusMultiplier = 5000;     // 0.5x bonus for fast completion
    uint256 public perfectScoreBonus = 2000;         // 0.2x bonus for perfect score
    uint256 public gasOptimizationBonus = 1500;      // 0.15x bonus for gas efficiency

    // Speed thresholds (in seconds)
    mapping(uint256 => uint256) public speedThresholds;

    // Track rewards
    mapping(address => uint256) public totalRewardsEarned;
    mapping(uint256 => bool) public rewardDistributed;

    // Sponsored rewards pool
    mapping(uint256 => uint256) public sponsoredRewards; // challengeId => amount
    uint256 public platformRewardPool;

    // Events
    event RewardDistributed(
        uint256 indexed solutionId,
        address indexed user,
        uint256 xpAmount,
        uint256[] badges
    );
    
    event BadgeEarned(address indexed user, uint256 indexed badgeId, string reason);
    event SponsoredRewardAdded(uint256 indexed challengeId, uint256 amount);
    event PlatformRewardPoolIncreased(uint256 amount);

    // Errors
    error Unauthorized();
    error AlreadyDistributed();
    error InvalidAddress();
    error InsufficientPoolBalance();

    constructor(
        address _experienceToken,
        address _achievementBadges,
        address _userProfile,
        address _challengeRegistry,
        address _solutionSubmission
    ) {
        _initializeOwner(msg.sender);
        
        if (_experienceToken == address(0) || 
            _achievementBadges == address(0) ||
            _userProfile == address(0) ||
            _challengeRegistry == address(0) ||
            _solutionSubmission == address(0)) {
            revert InvalidAddress();
        }

        experienceToken = _experienceToken;
        achievementBadges = _achievementBadges;
        userProfile = _userProfile;
        challengeRegistry = _challengeRegistry;
        solutionSubmission = _solutionSubmission;

        // Initialize difficulty multipliers
        difficultyMultipliers[0] = 10000;  // BEGINNER: 1x
        difficultyMultipliers[1] = 15000;  // EASY: 1.5x
        difficultyMultipliers[2] = 25000;  // MEDIUM: 2.5x
        difficultyMultipliers[3] = 40000;  // HARD: 4x
        difficultyMultipliers[4] = 60000;  // EXPERT: 6x

        // Speed thresholds (in seconds)
        speedThresholds[0] = 1800;  // BEGINNER: 30 min
        speedThresholds[1] = 3600;  // EASY: 1 hour
        speedThresholds[2] = 7200;  // MEDIUM: 2 hours
        speedThresholds[3] = 14400; // HARD: 4 hours
        speedThresholds[4] = 28800; // EXPERT: 8 hours
    }

    /**
     * @notice Distribute rewards for a completed solution
     * @param solutionId The solution ID
     * @param score The score achieved (0-100)
     * @param gasUsed Gas used by the solution
     */
    function distributeReward(
        uint256 solutionId,
        uint256 score,
        uint256 gasUsed
    ) external {
        // Only SolutionValidator can call this
        if (msg.sender != owner() && 
            !_isAuthorizedCaller(msg.sender)) {
            revert Unauthorized();
        }

        if (rewardDistributed[solutionId]) revert AlreadyDistributed();
        rewardDistributed[solutionId] = true;

        // Get solution details
        (bool success, bytes memory data) = solutionSubmission.call(
            abi.encodeWithSignature("getSolution(uint256)", solutionId)
        );
        require(success, "Failed to get solution");

        // Decode solution data (simplified - in production use proper decoding)
        (
            ,
            address submitter,
            uint256 challengeId,
            ,
            ,
            ,
            ,
            ,
            uint256 completionTime
        ) = abi.decode(data, (uint256, address, uint256, address, string, uint256, uint8, uint256, uint256));

        // Get challenge details for base points and difficulty
        (success, data) = challengeRegistry.call(
            abi.encodeWithSignature("getChallenge(uint256)", challengeId)
        );
        require(success, "Failed to get challenge");

        // Decode challenge (get basePoints and difficulty)
        (
            ,
            ,
            ,
            ,
            uint256 difficulty,
            ,
            uint256 basePoints,
            ,
            ,
            ,
            ,
        ) = abi.decode(data, (uint256, string, string, string, uint256, uint256, uint256, uint256, bytes32, address, uint256, bool));

        // Calculate total XP reward
        uint256 xpReward = _calculateXPReward(
            basePoints,
            difficulty,
            score,
            completionTime,
            gasUsed
        );

        // Mint XP tokens
        (success, ) = experienceToken.call(
            abi.encodeWithSignature("mint(address,uint256)", submitter, xpReward)
        );
        require(success, "XP mint failed");

        // Update user profile
        (success, data) = userProfile.call(
            abi.encodeWithSignature("addressToTokenId(address)", submitter)
        );
        require(success, "Failed to get profile");
        
        uint256 profileTokenId = abi.decode(data, (uint256));

        // Update XP in profile
        (success, ) = userProfile.call(
            abi.encodeWithSignature("updateXP(uint256,uint256)", profileTokenId, xpReward)
        );
        require(success, "Profile update failed");

        // Add completed challenge
        (success, ) = userProfile.call(
            abi.encodeWithSignature("addCompletedChallenge(uint256,uint256)", profileTokenId, challengeId)
        );
        require(success, "Challenge record failed");

        // Check and award badges
        uint256[] memory earnedBadges = _checkAndAwardBadges(
            submitter,
            profileTokenId,
            score,
            completionTime,
            difficulty,
            gasUsed
        );

        // Distribute any sponsored rewards
        if (sponsoredRewards[challengeId] > 0) {
            _distributeSponsoredReward(submitter, challengeId);
        }

        totalRewardsEarned[submitter] += xpReward;

        emit RewardDistributed(solutionId, submitter, xpReward, earnedBadges);
    }

    /**
     * @notice Calculate total XP reward with bonuses
     */
    function _calculateXPReward(
        uint256 basePoints,
        uint256 difficulty,
        uint256 score,
        uint256 completionTime,
        uint256 gasUsed
    ) internal view returns (uint256) {
        // Base reward: basePoints * difficultyMultiplier
        uint256 reward = (basePoints * difficultyMultipliers[difficulty]) / 10000;

        // Score multiplier (score / 100)
        reward = (reward * score) / 100;

        // Speed bonus
        if (completionTime <= speedThresholds[difficulty]) {
            uint256 speedBonus = (reward * speedBonusMultiplier) / 10000;
            reward += speedBonus;
        }

        // Perfect score bonus
        if (score == 100) {
            uint256 perfectBonus = (reward * perfectScoreBonus) / 10000;
            reward += perfectBonus;
        }

        // Gas optimization bonus (if gasUsed is very low)
        // This would need proper calculation based on expected gas
        if (gasUsed > 0 && gasUsed < 500000) {
            uint256 gasBonus = (reward * gasOptimizationBonus) / 10000;
            reward += gasBonus;
        }

        return reward;
    }

    /**
     * @notice Check conditions and award badges
     */
    function _checkAndAwardBadges(
        address user,
        uint256 profileTokenId,
        uint256 score,
        uint256 completionTime,
        uint256 difficulty,
        uint256 gasUsed
    ) internal returns (uint256[] memory) {
        uint256[] memory badges = new uint256[](10);
        uint256 badgeCount = 0;

        // Get profile data
        (bool success, bytes memory data) = userProfile.call(
            abi.encodeWithSignature("getProfile(uint256)", profileTokenId)
        );
        
        if (!success) return new uint256[](0);

        (
            uint256 level,
            uint256 totalXP,
            ,
            ,
            ,
            ,
            uint256 streak,
            uint256 totalSolutions,
        ) = abi.decode(data, (uint256, uint256, uint256[], uint256[], uint256, uint256, uint256, uint256, uint256));

        // First Blood - First solution
        if (totalSolutions == 0) {
            badges[badgeCount++] = BADGE_FIRST_BLOOD;
            _mintBadge(user, BADGE_FIRST_BLOOD, "First challenge completed!");
        }

        // Rising Star - Level 5
        if (level == 5) {
            badges[badgeCount++] = BADGE_RISING_STAR;
            _mintBadge(user, BADGE_RISING_STAR, "Reached Level 5!");
        }

        // Elite Coder - Level 10
        if (level == 10) {
            badges[badgeCount++] = BADGE_ELITE_CODER;
            _mintBadge(user, BADGE_ELITE_CODER, "Reached Level 10!");
        }

        // Speed Demon - Fast completion
        if (completionTime <= speedThresholds[difficulty]) {
            badges[badgeCount++] = BADGE_SPEED_DEMON;
            _mintBadge(user, BADGE_SPEED_DEMON, "Lightning fast completion!");
        }

        // Perfect Score
        if (score == 100) {
            badges[badgeCount++] = BADGE_PERFECT_SCORE;
            _mintBadge(user, BADGE_PERFECT_SCORE, "Perfect score achieved!");
        }

        // Streak badges
        if (streak == 7) {
            badges[badgeCount++] = BADGE_CONSISTENT;
            _mintBadge(user, BADGE_CONSISTENT, "7-day streak!");
        }
        if (streak == 30) {
            badges[badgeCount++] = BADGE_STREAK_MASTER;
            _mintBadge(user, BADGE_STREAK_MASTER, "30-day streak!");
        }

        // Gas Optimizer
        if (gasUsed > 0 && gasUsed < 300000) {
            badges[badgeCount++] = BADGE_GAS_OPTIMIZER;
            _mintBadge(user, BADGE_GAS_OPTIMIZER, "Excellent gas optimization!");
        }

        // Return only filled badges
        uint256[] memory result = new uint256[](badgeCount);
        for (uint256 i = 0; i < badgeCount; i++) {
            result[i] = badges[i];
        }
        return result;
    }

    /**
     * @notice Mint a badge for user
     */
    function _mintBadge(address user, uint256 badgeId, string memory reason) internal {
        (bool success, bytes memory data) = achievementBadges.call(
            abi.encodeWithSignature("hasBadge(address,uint256)", user, badgeId)
        );
        
        if (success) {
            bool alreadyHas = abi.decode(data, (bool));
            if (!alreadyHas) {
                (success, ) = achievementBadges.call(
                    abi.encodeWithSignature("mintBadge(address,uint256)", user, badgeId)
                );
                
                if (success) {
                    emit BadgeEarned(user, badgeId, reason);
                }
            }
        }
    }

    /**
     * @notice Distribute sponsored reward
     */
    function _distributeSponsoredReward(address user, uint256 challengeId) internal {
        uint256 amount = sponsoredRewards[challengeId];
        if (amount > 0 && platformRewardPool >= amount) {
            platformRewardPool -= amount;
            sponsoredRewards[challengeId] = 0;
            
            // Transfer ETH or tokens (simplified - just track for now)
            (bool success, ) = payable(user).call{value: amount}("");
            require(success, "Reward transfer failed");
        }
    }

    function _isAuthorizedCaller(address caller) internal view returns (bool) {
        // Check if caller is an authorized contract
        return caller == solutionSubmission || 
               caller == userProfile ||
               caller == challengeRegistry;
    }

    // Admin functions

    function addSponsoredReward(uint256 challengeId) external payable {
        sponsoredRewards[challengeId] += msg.value;
        platformRewardPool += msg.value;
        emit SponsoredRewardAdded(challengeId, msg.value);
    }

    function fundRewardPool() external payable {
        platformRewardPool += msg.value;
        emit PlatformRewardPoolIncreased(msg.value);
    }

    function setDifficultyMultiplier(uint256 difficulty, uint256 multiplier) 
        external 
        onlyOwner 
    {
        difficultyMultipliers[difficulty] = multiplier;
    }

    function setSpeedThreshold(uint256 difficulty, uint256 threshold) 
        external 
        onlyOwner 
    {
        speedThresholds[difficulty] = threshold;
    }

    function setBonusMultipliers(
        uint256 _speedBonus,
        uint256 _perfectBonus,
        uint256 _gasBonus
    ) external onlyOwner {
        speedBonusMultiplier = _speedBonus;
        perfectScoreBonus = _perfectBonus;
        gasOptimizationBonus = _gasBonus;
    }

    function withdrawPool(uint256 amount) external onlyOwner {
        if (amount > platformRewardPool) revert InsufficientPoolBalance();
        platformRewardPool -= amount;
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    receive() external payable {
        platformRewardPool += msg.value;
        emit PlatformRewardPoolIncreased(msg.value);
    }
}
