// Contract addresses - update after deployment
export const CONTRACTS = {
  ExperienceToken: '0x...',
  AchievementBadges: '0x...',
  UserProfile: '0x...',
  ChallengeRegistry: '0x...',
  SolutionSubmission: '0x...',
  SolutionValidator: '0x...',
  RewardDistributor: '0x...',
  LeaderboardManager: '0x...',
};

// Network configuration
export const SUPPORTED_CHAINS = {
  hardhat: {
    id: 31337,
    name: 'Hardhat',
    rpcUrl: 'http://127.0.0.1:8545',
    blockExplorer: '',
  },
  sepolia: {
    id: 11155111,
    name: 'Sepolia',
    rpcUrl: 'https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY',
    blockExplorer: 'https://sepolia.etherscan.io',
  },
};

// Challenge difficulties
export const DIFFICULTY = {
  BEGINNER: 0,
  EASY: 1,
  MEDIUM: 2,
  HARD: 3,
  EXPERT: 4,
};

export const DIFFICULTY_LABELS = {
  0: 'Beginner',
  1: 'Easy',
  2: 'Medium',
  3: 'Hard',
  4: 'Expert',
};

export const DIFFICULTY_COLORS = {
  0: 'bg-green-500',
  1: 'bg-blue-500',
  2: 'bg-yellow-500',
  3: 'bg-orange-500',
  4: 'bg-red-500',
};

// Challenge categories
export const CATEGORY = {
  DEFI: 0,
  NFT: 1,
  SECURITY: 2,
  GOVERNANCE: 3,
  GAMEFI: 4,
  INFRASTRUCTURE: 5,
  ADVANCED_PATTERNS: 6,
  GAS_OPTIMIZATION: 7,
};

export const CATEGORY_LABELS = {
  0: 'DeFi',
  1: 'NFT',
  2: 'Security',
  3: 'Governance',
  4: 'GameFi',
  5: 'Infrastructure',
  6: 'Advanced Patterns',
  7: 'Gas Optimization',
};

// Badge IDs
export const BADGES = {
  FIRST_BLOOD: 1,
  RISING_STAR: 2,
  ELITE_CODER: 3,
  SPEED_DEMON: 4,
  LIGHTNING_FAST: 5,
  CONSISTENT: 6,
  STREAK_MASTER: 7,
  DEFI_MASTER: 8,
  NFT_EXPERT: 9,
  SECURITY_SPECIALIST: 10,
  BUG_HUNTER: 11,
  GAS_OPTIMIZER: 12,
  COMMUNITY_HELPER: 13,
  PERFECT_SCORE: 14,
  EARLY_ADOPTER: 15,
};

// Level thresholds (XP required)
export const LEVEL_THRESHOLDS = {
  1: 0,
  2: 100,
  3: 250,
  4: 500,
  5: 1000,
  6: 2000,
  7: 4000,
  8: 8000,
  9: 16000,
  10: 32000,
};

// API endpoints
export const API_BASE_URL = 'https://api.chainquest.io';
export const IPFS_GATEWAY = 'https://ipfs.io/ipfs/';
