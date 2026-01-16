// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "solady/auth/Ownable.sol";

/**
 * @title SolutionSubmission
 * @notice Handles submission and storage of user solutions
 * @dev Links solutions to challenges and users, stores code hashes
 */
contract SolutionSubmission is Ownable {
    enum SolutionStatus {
        PENDING,
        VALIDATED,
        FAILED,
        REVIEWING
    }

    struct Solution {
        uint256 id;
        address submitter;
        uint256 challengeId;
        address contractAddress;    // Deployed solution contract
        string codeHash;            // IPFS hash of source code
        uint256 submittedAt;
        SolutionStatus status;
        uint256 gasUsed;
        uint256 score;              // 0-100
        uint256 completionTime;     // Time taken to solve (seconds)
    }

    struct ValidationResult {
        bool passed;
        string feedback;
        uint256 gasScore;           // Gas efficiency score
        uint256 securityScore;      // Security best practices score
        uint256 testsPassedCount;
        uint256 totalTestsCount;
    }

    // State
    mapping(uint256 => Solution) public solutions;
    mapping(uint256 => ValidationResult) public validationResults;
    mapping(address => uint256[]) public userSolutions;
    mapping(uint256 => uint256[]) public challengeSolutions;
    mapping(address => mapping(uint256 => bool)) public hasCompleted;
    
    uint256 public nextSolutionId = 1;
    
    // Authorized validators
    mapping(address => bool) public authorizedValidators;
    
    // Contract references
    address public challengeRegistry;
    address public userProfile;
    address public validator;

    // Events
    event SolutionSubmitted(
        uint256 indexed solutionId,
        address indexed submitter,
        uint256 indexed challengeId,
        address contractAddress
    );
    
    event SolutionValidated(
        uint256 indexed solutionId,
        SolutionStatus status,
        uint256 score
    );
    
    event ValidatorAuthorized(address indexed validator);
    event ValidatorRevoked(address indexed validator);

    // Errors
    error Unauthorized();
    error SolutionNotFound();
    error AlreadyCompleted();
    error InvalidAddress();
    error InvalidChallengeId();

    constructor(
        address _challengeRegistry,
        address _userProfile,
        address _validator
    ) {
        _initializeOwner(msg.sender);
        
        if (_challengeRegistry == address(0) || 
            _userProfile == address(0) || 
            _validator == address(0)) {
            revert InvalidAddress();
        }

        challengeRegistry = _challengeRegistry;
        userProfile = _userProfile;
        validator = _validator;
        
        authorizedValidators[_validator] = true;
        authorizedValidators[msg.sender] = true;
    }

    modifier onlyValidator() {
        if (!authorizedValidators[msg.sender]) revert Unauthorized();
        _;
    }

    /**
     * @notice Submit a solution for a challenge
     * @param challengeId The challenge being solved
     * @param contractAddress Address of the deployed solution contract
     * @param codeHash IPFS hash of the source code
     * @param completionTime Time taken to complete (in seconds)
     */
    function submitSolution(
        uint256 challengeId,
        address contractAddress,
        string calldata codeHash,
        uint256 completionTime
    ) external returns (uint256) {
        if (challengeId == 0) revert InvalidChallengeId();
        if (hasCompleted[msg.sender][challengeId]) revert AlreadyCompleted();

        uint256 solutionId = nextSolutionId++;

        solutions[solutionId] = Solution({
            id: solutionId,
            submitter: msg.sender,
            challengeId: challengeId,
            contractAddress: contractAddress,
            codeHash: codeHash,
            submittedAt: block.timestamp,
            status: SolutionStatus.PENDING,
            gasUsed: 0,
            score: 0,
            completionTime: completionTime
        });

        userSolutions[msg.sender].push(solutionId);
        challengeSolutions[challengeId].push(solutionId);

        emit SolutionSubmitted(solutionId, msg.sender, challengeId, contractAddress);

        return solutionId;
    }

    /**
     * @notice Mark solution as validated (called by SolutionValidator)
     */
    function markAsValidated(
        uint256 solutionId,
        SolutionStatus status,
        uint256 score,
        uint256 gasUsed,
        ValidationResult calldata result
    ) external onlyValidator {
        Solution storage solution = solutions[solutionId];
        if (solution.id == 0) revert SolutionNotFound();

        solution.status = status;
        solution.score = score;
        solution.gasUsed = gasUsed;

        validationResults[solutionId] = result;

        if (status == SolutionStatus.VALIDATED && result.passed) {
            hasCompleted[solution.submitter][solution.challengeId] = true;
        }

        emit SolutionValidated(solutionId, status, score);
    }

    /**
     * @notice Update solution status
     */
    function updateStatus(uint256 solutionId, SolutionStatus status) 
        external 
        onlyValidator 
    {
        Solution storage solution = solutions[solutionId];
        if (solution.id == 0) revert SolutionNotFound();

        solution.status = status;
    }

    // View functions

    /**
     * @notice Get solution details
     */
    function getSolution(uint256 solutionId) 
        external 
        view 
        returns (Solution memory) 
    {
        Solution memory solution = solutions[solutionId];
        if (solution.id == 0) revert SolutionNotFound();
        return solution;
    }

    /**
     * @notice Get validation result
     */
    function getValidationResult(uint256 solutionId) 
        external 
        view 
        returns (ValidationResult memory) 
    {
        return validationResults[solutionId];
    }

    /**
     * @notice Get all solutions by a user
     */
    function getUserSolutions(address user) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return userSolutions[user];
    }

    /**
     * @notice Get all solutions for a challenge
     */
    function getChallengeSolutions(uint256 challengeId) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return challengeSolutions[challengeId];
    }

    /**
     * @notice Get user's solution history with details
     */
    function getUserSolutionHistory(address user) 
        external 
        view 
        returns (Solution[] memory) 
    {
        uint256[] memory solutionIds = userSolutions[user];
        Solution[] memory history = new Solution[](solutionIds.length);

        for (uint256 i = 0; i < solutionIds.length; i++) {
            history[i] = solutions[solutionIds[i]];
        }

        return history;
    }

    /**
     * @notice Check if user completed a challenge
     */
    function hasUserCompleted(address user, uint256 challengeId) 
        external 
        view 
        returns (bool) 
    {
        return hasCompleted[user][challengeId];
    }

    /**
     * @notice Get best solution for a challenge (highest score)
     */
    function getBestSolution(uint256 challengeId) 
        external 
        view 
        returns (Solution memory) 
    {
        uint256[] memory solutionIds = challengeSolutions[challengeId];
        
        if (solutionIds.length == 0) {
            revert SolutionNotFound();
        }

        Solution memory best = solutions[solutionIds[0]];
        
        for (uint256 i = 1; i < solutionIds.length; i++) {
            Solution memory current = solutions[solutionIds[i]];
            if (current.score > best.score) {
                best = current;
            }
        }

        return best;
    }

    /**
     * @notice Get stats for a user
     */
    function getUserStats(address user) 
        external 
        view 
        returns (
            uint256 totalSubmissions,
            uint256 successfulSubmissions,
            uint256 averageScore,
            uint256 averageGasUsed
        ) 
    {
        uint256[] memory solutionIds = userSolutions[user];
        totalSubmissions = solutionIds.length;
        
        uint256 totalScore = 0;
        uint256 totalGas = 0;
        uint256 successCount = 0;

        for (uint256 i = 0; i < solutionIds.length; i++) {
            Solution memory solution = solutions[solutionIds[i]];
            
            if (solution.status == SolutionStatus.VALIDATED) {
                successCount++;
                totalScore += solution.score;
                totalGas += solution.gasUsed;
            }
        }

        successfulSubmissions = successCount;
        averageScore = successCount > 0 ? totalScore / successCount : 0;
        averageGasUsed = successCount > 0 ? totalGas / successCount : 0;
    }

    // Admin functions

    function authorizeValidator(address _validator) external onlyOwner {
        authorizedValidators[_validator] = true;
        emit ValidatorAuthorized(_validator);
    }

    function revokeValidator(address _validator) external onlyOwner {
        authorizedValidators[_validator] = false;
        emit ValidatorRevoked(_validator);
    }

    function setValidatorContract(address _validator) external onlyOwner {
        if (_validator == address(0)) revert InvalidAddress();
        validator = _validator;
        authorizedValidators[_validator] = true;
    }

    function setChallengeRegistry(address _registry) external onlyOwner {
        if (_registry == address(0)) revert InvalidAddress();
        challengeRegistry = _registry;
    }

    function setUserProfile(address _profile) external onlyOwner {
        if (_profile == address(0)) revert InvalidAddress();
        userProfile = _profile;
    }
}
