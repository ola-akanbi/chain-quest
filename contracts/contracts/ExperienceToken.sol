// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "solady/tokens/ERC20.sol";
import {Ownable} from "solady/auth/Ownable.sol";

/**
 * @title ExperienceToken
 * @notice ERC20 token representing XP on the platform
 * @dev Non-transferable by default, only authorized contracts can mint
 */
contract ExperienceToken is ERC20, Ownable {
    // Authorized minters (RewardDistributor, etc.)
    mapping(address => bool) public authorizedMinters;
    
    // Staking
    struct StakeInfo {
        uint256 amount;
        uint256 stakedAt;
        uint256 lockPeriod;  // in seconds
    }
    
    mapping(address => StakeInfo) public stakes;
    
    uint256 public constant MIN_LOCK_PERIOD = 7 days;
    uint256 public constant MAX_LOCK_PERIOD = 365 days;
    
    // APY for staking (basis points: 1000 = 10%)
    uint256 public stakingAPY = 1000; // 10% APY
    
    // Transfer settings
    bool public transfersEnabled = false;

    // Events
    event MinterAuthorized(address indexed minter);
    event MinterRevoked(address indexed minter);
    event Staked(address indexed user, uint256 amount, uint256 lockPeriod);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);
    event TransfersToggled(bool enabled);

    // Errors
    error Unauthorized();
    error TransfersDisabled();
    error InvalidLockPeriod();
    error StillLocked();
    error NoStake();
    error InsufficientBalance();

    constructor() {
        _initializeOwner(msg.sender);
        authorizedMinters[msg.sender] = true;
    }

    // Metadata
    function name() public pure override returns (string memory) {
        return "ChainQuest XP";
    }

    function symbol() public pure override returns (string memory) {
        return "XP";
    }

    // Minting (only by authorized contracts)
    function mint(address to, uint256 amount) external {
        if (!authorizedMinters[msg.sender]) revert Unauthorized();
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        if (!authorizedMinters[msg.sender]) revert Unauthorized();
        _burn(from, amount);
    }

    // Staking functions
    function stake(uint256 amount, uint256 lockPeriod) external {
        if (lockPeriod < MIN_LOCK_PERIOD || lockPeriod > MAX_LOCK_PERIOD) {
            revert InvalidLockPeriod();
        }
        if (balanceOf(msg.sender) < amount) revert InsufficientBalance();

        // If already staking, claim rewards first
        if (stakes[msg.sender].amount > 0) {
            _claimStakingRewards(msg.sender);
        }

        stakes[msg.sender] = StakeInfo({
            amount: stakes[msg.sender].amount + amount,
            stakedAt: block.timestamp,
            lockPeriod: lockPeriod
        });

        _burn(msg.sender, amount);
        
        emit Staked(msg.sender, amount, lockPeriod);
    }

    function unstake() external {
        StakeInfo memory stakeInfo = stakes[msg.sender];
        if (stakeInfo.amount == 0) revert NoStake();
        
        if (block.timestamp < stakeInfo.stakedAt + stakeInfo.lockPeriod) {
            revert StillLocked();
        }

        uint256 reward = calculateStakingReward(msg.sender);
        uint256 total = stakeInfo.amount + reward;

        delete stakes[msg.sender];
        
        _mint(msg.sender, total);

        emit Unstaked(msg.sender, stakeInfo.amount, reward);
    }

    function _claimStakingRewards(address user) internal {
        uint256 reward = calculateStakingReward(user);
        if (reward > 0) {
            stakes[user].stakedAt = block.timestamp;
            _mint(user, reward);
        }
    }

    function calculateStakingReward(address user) public view returns (uint256) {
        StakeInfo memory stakeInfo = stakes[user];
        if (stakeInfo.amount == 0) return 0;

        uint256 timeStaked = block.timestamp - stakeInfo.stakedAt;
        
        // APY calculation: reward = principal * APY * time / (365 days * 10000)
        uint256 reward = (stakeInfo.amount * stakingAPY * timeStaked) / (365 days * 10000);
        
        return reward;
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

    function setStakingAPY(uint256 newAPY) external onlyOwner {
        stakingAPY = newAPY;
    }

    function toggleTransfers(bool enabled) external onlyOwner {
        transfersEnabled = enabled;
        emit TransfersToggled(enabled);
    }

    // Override transfer to make XP non-transferable by default
    function transfer(address to, uint256 amount) public override returns (bool) {
        if (!transfersEnabled && !authorizedMinters[msg.sender]) {
            revert TransfersDisabled();
        }
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) 
        public 
        override 
        returns (bool) 
    {
        if (!transfersEnabled && !authorizedMinters[msg.sender]) {
            revert TransfersDisabled();
        }
        return super.transferFrom(from, to, amount);
    }
}
