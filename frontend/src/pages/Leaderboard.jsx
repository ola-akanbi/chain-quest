import { useState } from 'react';
import { Trophy, TrendingUp, Award as AwardIcon, Medal } from 'lucide-react';
import { motion } from 'framer-motion';

const MOCK_LEADERBOARD = [
  { rank: 1, address: '0x1234...5678', level: 10, xp: 35000, badges: 25, avatar: '🥇' },
  { rank: 2, address: '0x2345...6789', level: 9, xp: 28000, badges: 22, avatar: '🥈' },
  { rank: 3, address: '0x3456...7890', level: 9, xp: 25000, badges: 20, avatar: '🥉' },
  { rank: 4, address: '0x4567...8901', level: 8, xp: 20000, badges: 18, avatar: '👤' },
  { rank: 5, address: '0x5678...9012', level: 8, xp: 18500, badges: 17, avatar: '👤' },
  { rank: 6, address: '0x6789...0123', level: 7, xp: 15000, badges: 15, avatar: '👤' },
  { rank: 7, address: '0x7890...1234', level: 7, xp: 14000, badges: 14, avatar: '👤' },
  { rank: 8, address: '0x8901...2345', level: 6, xp: 12000, badges: 12, avatar: '👤' },
  { rank: 9, address: '0x9012...3456', level: 6, xp: 11000, badges: 11, avatar: '👤' },
  { rank: 10, address: '0x0123...4567', level: 5, xp: 9500, badges: 10, avatar: '👤' },
];

export default function Leaderboard() {
  const [timeframe, setTimeframe] = useState('all-time');
  const [category, setCategory] = useState('global');

  return (
    <div className="max-w-6xl mx-auto space-y-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center space-y-4"
      >
        <div className="inline-flex p-4 bg-yellow-500/20 rounded-full mb-4">
          <Trophy className="w-12 h-12 text-yellow-400" />
        </div>
        <h1 className="text-4xl font-bold">
          <span className="gradient-text">Leaderboard</span>
        </h1>
        <p className="text-gray-400">
          Top developers on ChainQuest
        </p>
      </motion.div>

      {/* Filters */}
      <div className="glass rounded-xl p-6">
        <div className="flex flex-wrap gap-4">
          {/* Timeframe */}
          <div className="flex-1 min-w-[200px]">
            <label className="block text-sm text-gray-400 mb-2">Timeframe</label>
            <select
              value={timeframe}
              onChange={(e) => setTimeframe(e.target.value)}
              className="w-full px-4 py-2 bg-dark-800 border border-dark-700 rounded-lg focus:outline-none focus:border-primary-500"
            >
              <option value="all-time">All Time</option>
              <option value="monthly">This Month</option>
              <option value="weekly">This Week</option>
            </select>
          </div>

          {/* Category */}
          <div className="flex-1 min-w-[200px]">
            <label className="block text-sm text-gray-400 mb-2">Category</label>
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="w-full px-4 py-2 bg-dark-800 border border-dark-700 rounded-lg focus:outline-none focus:border-primary-500"
            >
              <option value="global">Global</option>
              <option value="defi">DeFi</option>
              <option value="nft">NFT</option>
              <option value="security">Security</option>
            </select>
          </div>
        </div>
      </div>

      {/* Top 3 Podium */}
      <div className="grid md:grid-cols-3 gap-6">
        {MOCK_LEADERBOARD.slice(0, 3).map((user, index) => (
          <TopUserCard
            key={user.rank}
            user={user}
            delay={index * 0.1}
          />
        ))}
      </div>

      {/* Leaderboard Table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-dark-700">
                <th className="px-6 py-4 text-left text-sm font-semibold text-gray-400">
                  Rank
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-gray-400">
                  User
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-gray-400">
                  Level
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-gray-400">
                  Total XP
                </th>
                <th className="px-6 py-4 text-left text-sm font-semibold text-gray-400">
                  Badges
                </th>
              </tr>
            </thead>
            <tbody>
              {MOCK_LEADERBOARD.map((user) => (
                <LeaderboardRow key={user.rank} user={user} />
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Your Rank */}
      <div className="card bg-primary-500/10 border-primary-500/30">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="text-4xl">👤</div>
            <div>
              <div className="text-sm text-gray-400">Your Rank</div>
              <div className="text-2xl font-bold">#42</div>
            </div>
          </div>
          <div className="text-right">
            <div className="text-sm text-gray-400">Total XP</div>
            <div className="text-2xl font-bold text-yellow-400">3,450</div>
          </div>
        </div>
      </div>
    </div>
  );
}

function TopUserCard({ user, delay }) {
  const getRankColor = (rank) => {
    switch (rank) {
      case 1:
        return 'from-yellow-500 to-yellow-600';
      case 2:
        return 'from-gray-400 to-gray-500';
      case 3:
        return 'from-orange-600 to-orange-700';
      default:
        return 'from-primary-500 to-purple-600';
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
      className="card text-center"
    >
      <div className={`inline-flex w-20 h-20 rounded-full bg-gradient-to-br ${getRankColor(user.rank)} items-center justify-center text-4xl mb-4`}>
        {user.avatar}
      </div>
      
      <div className="text-sm text-gray-400 mb-1">Rank #{user.rank}</div>
      <div className="font-mono text-lg font-semibold mb-4">{user.address}</div>
      
      <div className="grid grid-cols-3 gap-4 pt-4 border-t border-dark-700">
        <div>
          <div className="text-2xl font-bold gradient-text">{user.level}</div>
          <div className="text-xs text-gray-400">Level</div>
        </div>
        <div>
          <div className="text-2xl font-bold text-yellow-400">
            {(user.xp / 1000).toFixed(1)}k
          </div>
          <div className="text-xs text-gray-400">XP</div>
        </div>
        <div>
          <div className="text-2xl font-bold text-purple-400">{user.badges}</div>
          <div className="text-xs text-gray-400">Badges</div>
        </div>
      </div>
    </motion.div>
  );
}

function LeaderboardRow({ user }) {
  const getRankDisplay = (rank) => {
    if (rank <= 3) {
      const medals = ['🥇', '🥈', '🥉'];
      return (
        <div className="flex items-center space-x-2">
          <span className="text-2xl">{medals[rank - 1]}</span>
          <span className="font-bold">#{rank}</span>
        </div>
      );
    }
    return <span className="text-gray-400">#{rank}</span>;
  };

  return (
    <tr className="border-b border-dark-700/50 hover:bg-dark-750 transition-colors">
      <td className="px-6 py-4">
        {getRankDisplay(user.rank)}
      </td>
      <td className="px-6 py-4">
        <div className="flex items-center space-x-3">
          <div className="text-2xl">{user.avatar}</div>
          <span className="font-mono">{user.address}</span>
        </div>
      </td>
      <td className="px-6 py-4">
        <div className="level-badge text-sm">
          {user.level}
        </div>
      </td>
      <td className="px-6 py-4">
        <span className="font-semibold text-yellow-400">
          {user.xp.toLocaleString()}
        </span>
      </td>
      <td className="px-6 py-4">
        <span className="font-semibold text-purple-400">
          {user.badges}
        </span>
      </td>
    </tr>
  );
}
