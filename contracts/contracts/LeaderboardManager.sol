// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "solady/auth/Ownable.sol";

/**
 * @title LeaderboardManager
 * @notice Manages global and category-based leaderboards
 * @dev Tracks rankings, competitions, and distributes prizes
 */
contract LeaderboardManager is Ownable {
    struct LeaderboardEntry {
        address user;
        uint256 score;
        uint256 lastUpdated;
        uint256 rank;
    }

    struct Competition {
        uint256 id;
        string name;
        uint256 startTime;
        uint256 endTime;
        uint256 prizePool;
        uint256[] topScorers;
        bool finalized;
        uint256 category; // 0 = global, 1-8 = specific categories
    }

    // Global leaderboard
    mapping(address => uint256) public globalScores;
    address[] public topUsers;
    uint256 public constant MAX_LEADERBOARD_SIZE = 100;

    // Category leaderboards (matches ChallengeRegistry categories)
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

    mapping(Category => mapping(address => uint256)) public categoryScores;
    mapping(Category => address[]) public categoryTopUsers;

    // Competitions
    mapping(uint256 => Competition) public competitions;
    uint256 public nextCompetitionId = 1;
    uint256[] public activeCompetitions;

    // Contract references
    address public userProfile;
    address public solutionSubmission;

    // Events
    event LeaderboardUpdated(
        address indexed user,
        uint256 newScore,
        uint256 newRank
    );
    
    event CategoryLeaderboardUpdated(
        address indexed user,
        Category indexed category,
        uint256 newScore
    );
    
    event CompetitionCreated(
        uint256 indexed competitionId,
        string name,
        uint256 startTime,
        uint256 endTime
    );
    
    event CompetitionFinalized(
        uint256 indexed competitionId,
        address[] winners,
        uint256[] prizes
    );

    // Errors
    error Unauthorized();
    error InvalidAddress();
    error CompetitionNotActive();
    error CompetitionAlreadyFinalized();
    error InvalidTimeRange();

    // Authorized updaters
    mapping(address => bool) public authorizedUpdaters;

    constructor(address _userProfile, address _solutionSubmission) {
        _initializeOwner(msg.sender);
        
        if (_userProfile == address(0) || _solutionSubmission == address(0)) {
            revert InvalidAddress();
        }

        userProfile = _userProfile;
        solutionSubmission = _solutionSubmission;
        authorizedUpdaters[msg.sender] = true;
    }

    modifier onlyAuthorized() {
        if (!authorizedUpdaters[msg.sender] && msg.sender != owner()) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @notice Update global leaderboard
     * @param user User address
     * @param scoreToAdd Score to add
     */
    function updateLeaderboard(address user, uint256 scoreToAdd) 
        external 
        onlyAuthorized 
    {
        globalScores[user] += scoreToAdd;
        
        // Update top users list
        _updateTopUsers(user);
        
        // Get new rank
        uint256 rank = _getUserRank(user);

        // Update best rank in profile
        (bool success, ) = userProfile.call(
            abi.encodeWithSignature(
                "addressToTokenId(address)",
                user
            )
        );
        
        if (success) {
            // Update in profile (simplified)
            (success, ) = userProfile.call(
                abi.encodeWithSignature(
                    "updateBestRank(uint256,uint256)",
                    0, // Would need actual tokenId
                    rank
                )
            );
        }

        emit LeaderboardUpdated(user, globalScores[user], rank);
    }

    /**
     * @notice Update category leaderboard
     */
    function updateCategoryLeaderboard(
        address user,
        Category category,
        uint256 scoreToAdd
    ) external onlyAuthorized {
        categoryScores[category][user] += scoreToAdd;
        
        // Update category top users
        _updateCategoryTopUsers(category, user);

        emit CategoryLeaderboardUpdated(user, category, categoryScores[category][user]);
    }

    /**
     * @notice Update top users array (keep sorted)
     */
    function _updateTopUsers(address user) internal {
        // Check if user already in top list
        bool exists = false;
        uint256 existingIndex = 0;
        
        for (uint256 i = 0; i < topUsers.length; i++) {
            if (topUsers[i] == user) {
                exists = true;
                existingIndex = i;
                break;
            }
        }

        if (!exists && topUsers.length < MAX_LEADERBOARD_SIZE) {
            topUsers.push(user);
        }

        // Bubble sort (simple, can be optimized)
        _sortTopUsers();

        // Keep only top MAX_LEADERBOARD_SIZE users
        if (topUsers.length > MAX_LEADERBOARD_SIZE) {
            topUsers.pop();
        }
    }

    /**
     * @notice Simple bubble sort for top users
     */
    function _sortTopUsers() internal {
        uint256 length = topUsers.length;
        
        for (uint256 i = 0; i < length; i++) {
            for (uint256 j = i + 1; j < length; j++) {
                if (globalScores[topUsers[i]] < globalScores[topUsers[j]]) {
                    address temp = topUsers[i];
                    topUsers[i] = topUsers[j];
                    topUsers[j] = temp;
                }
            }
        }
    }

    /**
     * @notice Update category top users
     */
    function _updateCategoryTopUsers(Category category, address user) internal {
        address[] storage catTopUsers = categoryTopUsers[category];
        
        bool exists = false;
        for (uint256 i = 0; i < catTopUsers.length; i++) {
            if (catTopUsers[i] == user) {
                exists = true;
                break;
            }
        }

        if (!exists && catTopUsers.length < MAX_LEADERBOARD_SIZE) {
            catTopUsers.push(user);
        }

        // Sort
        _sortCategoryTopUsers(category);

        if (catTopUsers.length > MAX_LEADERBOARD_SIZE) {
            catTopUsers.pop();
        }
    }

    /**
     * @notice Sort category top users
     */
    function _sortCategoryTopUsers(Category category) internal {
        address[] storage catTopUsers = categoryTopUsers[category];
        uint256 length = catTopUsers.length;
        
        for (uint256 i = 0; i < length; i++) {
            for (uint256 j = i + 1; j < length; j++) {
                if (categoryScores[category][catTopUsers[i]] < 
                    categoryScores[category][catTopUsers[j]]) {
                    address temp = catTopUsers[i];
                    catTopUsers[i] = catTopUsers[j];
                    catTopUsers[j] = temp;
                }
            }
        }
    }

    /**
     * @notice Get user's rank
     */
    function _getUserRank(address user) internal view returns (uint256) {
        for (uint256 i = 0; i < topUsers.length; i++) {
            if (topUsers[i] == user) {
                return i + 1; // Rank starts at 1
            }
        }
        return 0; // Not in top 100
    }

    /**
     * @notice Get top N users
     */
    function getTopUsers(uint256 count) 
        external 
        view 
        returns (LeaderboardEntry[] memory) 
    {
        uint256 length = count > topUsers.length ? topUsers.length : count;
        LeaderboardEntry[] memory entries = new LeaderboardEntry[](length);

        for (uint256 i = 0; i < length; i++) {
            address user = topUsers[i];
            entries[i] = LeaderboardEntry({
                user: user,
                score: globalScores[user],
                lastUpdated: block.timestamp,
                rank: i + 1
            });
        }

        return entries;
    }

    /**
     * @notice Get category top users
     */
    function getCategoryTopUsers(Category category, uint256 count)
        external
        view
        returns (LeaderboardEntry[] memory)
    {
        address[] storage catTopUsers = categoryTopUsers[category];
        uint256 length = count > catTopUsers.length ? catTopUsers.length : count;
        LeaderboardEntry[] memory entries = new LeaderboardEntry[](length);

        for (uint256 i = 0; i < length; i++) {
            address user = catTopUsers[i];
            entries[i] = LeaderboardEntry({
                user: user,
                score: categoryScores[category][user],
                lastUpdated: block.timestamp,
                rank: i + 1
            });
        }

        return entries;
    }

    /**
     * @notice Get user rank and score
     */
    function getUserRankAndScore(address user) 
        external 
        view 
        returns (uint256 rank, uint256 score) 
    {
        rank = _getUserRank(user);
        score = globalScores[user];
    }

    // Competition functions

    /**
     * @notice Create a new competition
     */
    function createCompetition(
        string calldata name,
        uint256 startTime,
        uint256 endTime,
        uint256 category
    ) external payable onlyOwner returns (uint256) {
        if (endTime <= startTime || startTime < block.timestamp) {
            revert InvalidTimeRange();
        }

        uint256 competitionId = nextCompetitionId++;

        competitions[competitionId] = Competition({
            id: competitionId,
            name: name,
            startTime: startTime,
            endTime: endTime,
            prizePool: msg.value,
            topScorers: new uint256[](0),
            finalized: false,
            category: category
        });

        activeCompetitions.push(competitionId);

        emit CompetitionCreated(competitionId, name, startTime, endTime);

        return competitionId;
    }

    /**
     * @notice Finalize competition and distribute prizes
     */
    function finalizeCompetition(uint256 competitionId) external onlyOwner {
        Competition storage competition = competitions[competitionId];
        
        if (block.timestamp < competition.endTime) {
            revert CompetitionNotActive();
        }
        
        if (competition.finalized) {
            revert CompetitionAlreadyFinalized();
        }

        competition.finalized = true;

        // Get top 3 users for this competition period
        LeaderboardEntry[] memory topScorers = this.getTopUsers(3);
        
        address[] memory winners = new address[](topScorers.length);
        uint256[] memory prizes = new uint256[](topScorers.length);

        // Prize distribution: 50%, 30%, 20%
        uint256[] memory prizePercentages = new uint256[](3);
        prizePercentages[0] = 5000; // 50%
        prizePercentages[1] = 3000; // 30%
        prizePercentages[2] = 2000; // 20%

        for (uint256 i = 0; i < topScorers.length && i < 3; i++) {
            winners[i] = topScorers[i].user;
            prizes[i] = (competition.prizePool * prizePercentages[i]) / 10000;
            
            // Transfer prize
            (bool success, ) = payable(winners[i]).call{value: prizes[i]}("");
            require(success, "Prize transfer failed");
        }

        // Remove from active competitions
        _removeFromActiveCompetitions(competitionId);

        emit CompetitionFinalized(competitionId, winners, prizes);
    }

    /**
     * @notice Remove competition from active list
     */
    function _removeFromActiveCompetitions(uint256 competitionId) internal {
        for (uint256 i = 0; i < activeCompetitions.length; i++) {
            if (activeCompetitions[i] == competitionId) {
                activeCompetitions[i] = activeCompetitions[activeCompetitions.length - 1];
                activeCompetitions.pop();
                break;
            }
        }
    }

    /**
     * @notice Get active competitions
     */
    function getActiveCompetitions() 
        external 
        view 
        returns (Competition[] memory) 
    {
        Competition[] memory active = new Competition[](activeCompetitions.length);
        
        for (uint256 i = 0; i < activeCompetitions.length; i++) {
            active[i] = competitions[activeCompetitions[i]];
        }

        return active;
    }

    // Admin functions

    function authorizeUpdater(address updater) external onlyOwner {
        authorizedUpdaters[updater] = true;
    }

    function revokeUpdater(address updater) external onlyOwner {
        authorizedUpdaters[updater] = false;
    }

    function setUserProfile(address _profile) external onlyOwner {
        if (_profile == address(0)) revert InvalidAddress();
        userProfile = _profile;
    }

    function setSolutionSubmission(address _submission) external onlyOwner {
        if (_submission == address(0)) revert InvalidAddress();
        solutionSubmission = _submission;
    }

    /**
     * @notice Emergency withdraw
     */
    function emergencyWithdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    receive() external payable {}
}
