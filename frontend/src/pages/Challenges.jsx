import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Search, Filter, Code2 } from 'lucide-react';
import { motion } from 'framer-motion';
import { DIFFICULTY_LABELS, CATEGORY_LABELS } from '../config/constants';

const MOCK_CHALLENGES = [
  {
    id: 1,
    title: 'Simple Storage Contract',
    description: 'Create a basic storage contract with get and set functions',
    difficulty: 0,
    category: 0,
    points: 100,
    completions: 1250,
    requiredLevel: 1,
  },
  {
    id: 2,
    title: 'Basic ERC20 Token',
    description: 'Implement a standard ERC20 token with minting',
    difficulty: 1,
    category: 0,
    points: 250,
    completions: 850,
    requiredLevel: 2,
  },
  {
    id: 3,
    title: 'NFT Marketplace',
    description: 'Build a simple NFT marketplace with listing and buying',
    difficulty: 2,
    category: 1,
    points: 500,
    completions: 420,
    requiredLevel: 5,
  },
  {
    id: 4,
    title: 'Find the Vulnerability',
    description: 'Identify and fix security vulnerabilities',
    difficulty: 3,
    category: 2,
    points: 1000,
    completions: 180,
    requiredLevel: 7,
  },
  {
    id: 5,
    title: 'DEX with AMM',
    description: 'Build a decentralized exchange with automated market maker',
    difficulty: 2,
    category: 0,
    points: 800,
    completions: 320,
    requiredLevel: 6,
  },
  {
    id: 6,
    title: 'DAO Governance',
    description: 'Implement a DAO with proposal and voting mechanisms',
    difficulty: 3,
    category: 3,
    points: 1200,
    completions: 150,
    requiredLevel: 8,
  },
];

export default function Challenges() {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedDifficulty, setSelectedDifficulty] = useState('all');
  const [selectedCategory, setSelectedCategory] = useState('all');

  const filteredChallenges = MOCK_CHALLENGES.filter((challenge) => {
    const matchesSearch = challenge.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         challenge.description.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesDifficulty = selectedDifficulty === 'all' || 
                              challenge.difficulty === parseInt(selectedDifficulty);
    const matchesCategory = selectedCategory === 'all' || 
                           challenge.category === parseInt(selectedCategory);
    
    return matchesSearch && matchesDifficulty && matchesCategory;
  });

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="space-y-2"
      >
        <h1 className="text-4xl font-bold">
          <span className="gradient-text">Challenges</span>
        </h1>
        <p className="text-gray-400">
          Choose a challenge and start coding. Earn XP and badges!
        </p>
      </motion.div>

      {/* Filters */}
      <div className="glass rounded-xl p-6 space-y-4">
        {/* Search */}
        <div className="relative">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search challenges..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-12 pr-4 py-3 bg-dark-800 border border-dark-700 rounded-lg focus:outline-none focus:border-primary-500 transition-colors"
          />
        </div>

        {/* Filter Row */}
        <div className="flex flex-wrap gap-4">
          {/* Difficulty Filter */}
          <div className="flex-1 min-w-[200px]">
            <label className="block text-sm text-gray-400 mb-2">Difficulty</label>
            <select
              value={selectedDifficulty}
              onChange={(e) => setSelectedDifficulty(e.target.value)}
              className="w-full px-4 py-2 bg-dark-800 border border-dark-700 rounded-lg focus:outline-none focus:border-primary-500"
            >
              <option value="all">All Levels</option>
              {Object.entries(DIFFICULTY_LABELS).map(([value, label]) => (
                <option key={value} value={value}>{label}</option>
              ))}
            </select>
          </div>

          {/* Category Filter */}
          <div className="flex-1 min-w-[200px]">
            <label className="block text-sm text-gray-400 mb-2">Category</label>
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="w-full px-4 py-2 bg-dark-800 border border-dark-700 rounded-lg focus:outline-none focus:border-primary-500"
            >
              <option value="all">All Categories</option>
              {Object.entries(CATEGORY_LABELS).map(([value, label]) => (
                <option key={value} value={value}>{label}</option>
              ))}
            </select>
          </div>

          {/* Results Count */}
          <div className="flex items-end">
            <div className="px-4 py-2 bg-dark-800 rounded-lg">
              <span className="text-gray-400">{filteredChallenges.length} challenges</span>
            </div>
          </div>
        </div>
      </div>

      {/* Challenges Grid */}
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredChallenges.map((challenge, index) => (
          <ChallengeCard
            key={challenge.id}
            challenge={challenge}
            delay={index * 0.1}
          />
        ))}
      </div>

      {filteredChallenges.length === 0 && (
        <div className="text-center py-20">
          <Code2 className="w-16 h-16 text-gray-600 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-gray-400 mb-2">
            No challenges found
          </h3>
          <p className="text-gray-500">
            Try adjusting your filters or search term
          </p>
        </div>
      )}
    </div>
  );
}

function ChallengeCard({ challenge, delay }) {
  const difficultyColors = {
    0: 'difficulty-beginner',
    1: 'difficulty-easy',
    2: 'difficulty-medium',
    3: 'difficulty-hard',
    4: 'difficulty-expert',
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
    >
      <Link
        to={`/challenges/${challenge.id}`}
        className="block card-interactive h-full"
      >
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-start justify-between mb-3">
            <div className="flex-1">
              <h3 className="font-semibold text-lg mb-2 line-clamp-2">
                {challenge.title}
              </h3>
            </div>
            <Code2 className="w-6 h-6 text-primary-400 flex-shrink-0 ml-2" />
          </div>

          {/* Description */}
          <p className="text-gray-400 text-sm mb-4 line-clamp-2 flex-grow">
            {challenge.description}
          </p>

          {/* Meta */}
          <div className="space-y-3">
            <div className="flex items-center justify-between text-sm">
              <span className={`badge ${difficultyColors[challenge.difficulty]}`}>
                {DIFFICULTY_LABELS[challenge.difficulty]}
              </span>
              <span className="badge bg-dark-700">
                {CATEGORY_LABELS[challenge.category]}
              </span>
            </div>

            <div className="flex items-center justify-between text-sm pt-3 border-t border-dark-700">
              <span className="text-yellow-400 font-semibold">
                {challenge.points} XP
              </span>
              <span className="text-gray-400">
                {challenge.completions.toLocaleString()} solved
              </span>
            </div>
          </div>

          {/* Required Level */}
          {challenge.requiredLevel > 1 && (
            <div className="mt-3 text-xs text-gray-500">
              Required Level: {challenge.requiredLevel}
            </div>
          )}
        </div>
      </Link>
    </motion.div>
  );
}
