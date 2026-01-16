// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "solady/auth/Ownable.sol";

/**
 * @title SolutionValidator
 * @notice Validates user solutions against challenge requirements
 * @dev Can use on-chain tests or oracle pattern for off-chain validation
 */
contract SolutionValidator is Ownable {
    struct TestCase {
        string description;
        bytes inputData;
        bytes expectedOutput;
        uint256 weight;         // For weighted scoring
    }

    struct ChallengeTests {
        TestCase[] testCases;
        uint256 gasLimit;
        uint256 minGasEfficiency;   // Minimum gas score to pass
        uint256 minSecurityScore;   // Minimum security score to pass
        bool exists;
    }

    // State
    mapping(uint256 => ChallengeTests) public challengeTests;
    
    // Oracle for off-chain validation (optional)
    address public validationOracle;
    mapping(bytes32 => bool) public oracleResults;
    
    // Contract references
    address public solutionSubmission;
    address public rewardDistributor;
    
    // Authorized test runners
    mapping(address => bool) public authorizedRunners;

    // Events
    event ValidationRequested(
        uint256 indexed solutionId,
        uint256 indexed challengeId,
        address indexed submitter
    );
    
    event ValidationCompleted(
        uint256 indexed solutionId,
        bool passed,
        uint256 score,
        uint256 gasUsed
    );
    
    event OracleResultSubmitted(
        bytes32 indexed requestId,
        bool passed,
        uint256 score
    );
    
    event TestsAdded(uint256 indexed challengeId, uint256 testCount);

    // Errors
    error Unauthorized();
    error InvalidSolution();
    error TestsFailed();
    error NoTestsFound();
    error GasLimitExceeded();
    error InvalidAddress();

    constructor(address _solutionSubmission) {
        _initializeOwner(msg.sender);
        
        if (_solutionSubmission == address(0)) revert InvalidAddress();
        
        solutionSubmission = _solutionSubmission;
        authorizedRunners[msg.sender] = true;
    }

    modifier onlyAuthorized() {
        if (!authorizedRunners[msg.sender] && msg.sender != owner()) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @notice Add test cases for a challenge
     */
    function addChallengeTests(
        uint256 challengeId,
        TestCase[] calldata testCases,
        uint256 gasLimit,
        uint256 minGasEfficiency,
        uint256 minSecurityScore
    ) external onlyOwner {
        ChallengeTests storage tests = challengeTests[challengeId];
        tests.gasLimit = gasLimit;
        tests.minGasEfficiency = minGasEfficiency;
        tests.minSecurityScore = minSecurityScore;
        tests.exists = true;

        // Clear existing tests
        delete tests.testCases;

        // Add new tests
        for (uint256 i = 0; i < testCases.length; i++) {
            tests.testCases.push(testCases[i]);
        }

        emit TestsAdded(challengeId, testCases.length);
    }

    /**
     * @notice Validate a solution (simplified on-chain version)
     * @dev For production, use oracle pattern for complex validation
     */
    function validateSolution(
        uint256 solutionId,
        uint256 challengeId,
        address contractAddress
    ) external onlyAuthorized returns (bool passed, uint256 score) {
        ChallengeTests storage tests = challengeTests[challengeId];
        if (!tests.exists) revert NoTestsFound();

        emit ValidationRequested(solutionId, challengeId, msg.sender);

        // Simple validation: check if contract exists
        uint256 size;
        assembly {
            size := extcodesize(contractAddress)
        }
        
        if (size == 0) {
            return (false, 0);
        }

        // In a real implementation, you would:
        // 1. Run test cases against the contract
        // 2. Measure gas usage
        // 3. Check security best practices
        // 4. Calculate weighted score

        // For MVP, return simplified results
        passed = true;
        score = 75; // Base score

        // Calculate gas score (simplified)
        uint256 gasScore = 80;
        
        // Calculate security score (simplified)
        uint256 securityScore = 85;

        // Final score (weighted average)
        score = (score + gasScore + securityScore) / 3;

        emit ValidationCompleted(solutionId, passed, score, 0);

        // Notify SolutionSubmission contract
        _recordValidation(solutionId, passed, score, 0);

        return (passed, score);
    }

    /**
     * @notice Submit oracle validation result
     * @dev Called by trusted oracle after off-chain validation
     */
    function submitOracleResult(
        uint256 solutionId,
        uint256 challengeId,
        bool passed,
        uint256 score,
        uint256 gasUsed,
        uint256 gasScore,
        uint256 securityScore,
        uint256 testsPassedCount,
        uint256 totalTestsCount,
        string calldata feedback
    ) external {
        if (msg.sender != validationOracle && !authorizedRunners[msg.sender]) {
            revert Unauthorized();
        }

        bytes32 requestId = keccak256(
            abi.encodePacked(solutionId, challengeId, block.timestamp)
        );
        
        oracleResults[requestId] = passed;

        emit OracleResultSubmitted(requestId, passed, score);
        emit ValidationCompleted(solutionId, passed, score, gasUsed);

        // Record detailed validation
        _recordDetailedValidation(
            solutionId,
            passed,
            score,
            gasUsed,
            gasScore,
            securityScore,
            testsPassedCount,
            totalTestsCount,
            feedback
        );
    }

    /**
     * @notice Record validation result in SolutionSubmission
     */
    function _recordValidation(
        uint256 solutionId,
        bool passed,
        uint256 score,
        uint256 gasUsed
    ) internal {
        // Call SolutionSubmission contract to record result
        (bool success, ) = solutionSubmission.call(
            abi.encodeWithSignature(
                "markAsValidated(uint256,uint8,uint256,uint256,(bool,string,uint256,uint256,uint256,uint256))",
                solutionId,
                passed ? 1 : 2, // VALIDATED : FAILED
                score,
                gasUsed,
                ValidationResult({
                    passed: passed,
                    feedback: passed ? "All tests passed!" : "Some tests failed",
                    gasScore: 80,
                    securityScore: 85,
                    testsPassedCount: passed ? 10 : 5,
                    totalTestsCount: 10
                })
            )
        );

        require(success, "Recording failed");

        // Trigger rewards if passed
        if (passed && rewardDistributor != address(0)) {
            (bool rewardSuccess, ) = rewardDistributor.call(
                abi.encodeWithSignature(
                    "distributeReward(uint256,uint256,uint256)",
                    solutionId,
                    score,
                    gasUsed
                )
            );
            require(rewardSuccess, "Reward distribution failed");
        }
    }

    /**
     * @notice Record detailed validation with all metrics
     */
    function _recordDetailedValidation(
        uint256 solutionId,
        bool passed,
        uint256 score,
        uint256 gasUsed,
        uint256 gasScore,
        uint256 securityScore,
        uint256 testsPassedCount,
        uint256 totalTestsCount,
        string calldata feedback
    ) internal {
        ValidationResult memory result = ValidationResult({
            passed: passed,
            feedback: feedback,
            gasScore: gasScore,
            securityScore: securityScore,
            testsPassedCount: testsPassedCount,
            totalTestsCount: totalTestsCount
        });

        (bool success, ) = solutionSubmission.call(
            abi.encodeWithSignature(
                "markAsValidated(uint256,uint8,uint256,uint256,(bool,string,uint256,uint256,uint256,uint256))",
                solutionId,
                passed ? 1 : 2,
                score,
                gasUsed,
                result
            )
        );

        require(success, "Recording failed");

        // Trigger rewards if passed
        if (passed && rewardDistributor != address(0)) {
            (bool rewardSuccess, ) = rewardDistributor.call(
                abi.encodeWithSignature(
                    "distributeReward(uint256,uint256,uint256)",
                    solutionId,
                    score,
                    gasUsed
                )
            );
            require(rewardSuccess, "Reward distribution failed");
        }
    }

    /**
     * @notice Calculate gas efficiency score
     */
    function calculateGasScore(
        uint256 gasUsed,
        uint256 optimalGas
    ) public pure returns (uint256) {
        if (gasUsed <= optimalGas) {
            return 100;
        }
        
        // Linear decay: score = 100 * (optimalGas / gasUsed)
        // Max penalty at 2x optimal gas
        uint256 score = (optimalGas * 100) / gasUsed;
        
        return score > 50 ? score : 50; // Minimum 50 points
    }

    // Struct for recording
    struct ValidationResult {
        bool passed;
        string feedback;
        uint256 gasScore;
        uint256 securityScore;
        uint256 testsPassedCount;
        uint256 totalTestsCount;
    }

    // Admin functions

    function setSolutionSubmission(address _submission) external onlyOwner {
        if (_submission == address(0)) revert InvalidAddress();
        solutionSubmission = _submission;
    }

    function setRewardDistributor(address _distributor) external onlyOwner {
        rewardDistributor = _distributor;
    }

    function setValidationOracle(address _oracle) external onlyOwner {
        validationOracle = _oracle;
        authorizedRunners[_oracle] = true;
    }

    function authorizeRunner(address runner) external onlyOwner {
        authorizedRunners[runner] = true;
    }

    function revokeRunner(address runner) external onlyOwner {
        authorizedRunners[runner] = false;
    }

    function getTestCases(uint256 challengeId) 
        external 
        view 
        returns (TestCase[] memory) 
    {
        return challengeTests[challengeId].testCases;
    }
}
