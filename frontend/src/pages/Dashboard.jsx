import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAccount, useReadContract } from 'wagmi';
import { 
  TrendingUp, 
  Award, 
  Zap, 
  Target,
  Clock,
  Trophy,
  ChevronRight 
} from 'lucide-react';
import { motion } from 'framer-motion';
import { CONTRACTS } from '../config/constants';

export default function Dashboard() {
  const { address } = useAccount();
  const [stats, setStats] = useState({
    level: 0,
    xp: 0,
    totalChallenges: 0,
    completedChallenges: 0,
    rank: 0,
    streak: 0,
  });

  // Simplified - in production use proper contract reads
  useEffect(() => {
    // Fetch user profile and stats
    // This would use useReadContract hooks
    setStats({
      level: 3,
      xp: 450,
      totalChallenges: 25,
      completedChallenges: 8,
      rank: 42,
      streak: 5,
    });
  }, [address]);

  const xpToNextLevel = 500;
  const xpProgress = (stats.xp / xpToNextLevel) * 100;

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Welcome Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="space-y-2"
      >
        <h1 className="text-4xl font-bold">
          Welcome back, <span className="gradient-text">Developer</span>
        </h1>
        <p className="text-gray-400">Track your progress and continue learning</p>
      </motion.div>

      {/* Stats Grid */}
      <div className="grid md:grid-cols-4 gap-6">
        <StatCard
          icon={TrendingUp}
          label="Level"
          value={stats.level}
          color="text-primary-400"
        />
        <StatCard
          icon={Zap}
          label="Total XP"
          value={stats.xp.toLocaleString()}
          color="text-yellow-400"
        />
        <StatCard
          icon={Target}
          label="Completed"
          value={`${stats.completedChallenges}/${stats.totalChallenges}`}
          color="text-green-400"
        />
        <StatCard
          icon={Trophy}
          label="Rank"
          value={`#${stats.rank}`}
          color="text-purple-400"
        />
      </div>

      {/* Level Progress */}
      <div className="card">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="text-lg font-semibold">Level {stats.level}</h3>
            <p className="text-sm text-gray-400">
              {stats.xp} / {xpToNextLevel} XP to Level {stats.level + 1}
            </p>
          </div>
          <div className="level-badge text-xl">
            {stats.level}
          </div>
        </div>
        
        <div className="progress-bar">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${xpProgress}%` }}
            transition={{ duration: 1, delay: 0.5 }}
            className="progress-bar-fill"
          />
        </div>
      </div>

      {/* Two Column Layout */}
      <div className="grid lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Continue Learning */}
          <section className="card">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-bold">Continue Learning</h2>
              <Link to="/challenges" className="text-primary-400 hover:text-primary-300 flex items-center space-x-1">
                <span>View All</span>
                <ChevronRight className="w-4 h-4" />
              </Link>
            </div>

            <div className="space-y-4">
              <ChallengeCard
                id={5}
                title="Build a DEX with AMM"
                difficulty="Medium"
                points={500}
                progress={65}
              />
              <ChallengeCard
                id={12}
                title="NFT Staking Contract"
                difficulty="Hard"
                points={1000}
                progress={30}
              />
            </div>
          </section>

          {/* Recent Activity */}
          <section className="card">
            <h2 className="text-2xl font-bold mb-6">Recent Activity</h2>
            
            <div className="space-y-4">
              <ActivityItem
                type="completed"
                title="Completed: Simple ERC20 Token"
                time="2 hours ago"
                xp={250}
              />
              <ActivityItem
                type="badge"
                title="Earned: Speed Demon Badge"
                time="1 day ago"
              />
              <ActivityItem
                type="completed"
                title="Completed: Storage Contract"
                time="2 days ago"
                xp={100}
              />
            </div>
          </section>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Streak */}
          <div className="card">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold">Current Streak</h3>
              <Clock className="w-5 h-5 text-orange-400" />
            </div>
            
            <div className="text-center py-4">
              <div className="text-5xl font-bold gradient-text mb-2">
                {stats.streak}
              </div>
              <div className="text-gray-400">Days</div>
            </div>

            <p className="text-sm text-gray-400 text-center mt-4">
              Keep it up! Solve a challenge today to maintain your streak.
            </p>
          </div>

          {/* Quick Actions */}
          <div className="card">
            <h3 className="font-semibold mb-4">Quick Actions</h3>
            
            <div className="space-y-2">
              <Link to="/challenges" className="block w-full btn btn-primary">
                Browse Challenges
              </Link>
              <Link to="/profile" className="block w-full btn btn-secondary">
                View Profile
              </Link>
              <Link to="/leaderboard" className="block w-full btn btn-ghost">
                Leaderboard
              </Link>
            </div>
          </div>

          {/* Latest Badges */}
          <div className="card">
            <h3 className="font-semibold mb-4">Latest Badges</h3>
            
            <div className="grid grid-cols-3 gap-3">
              {[1, 4, 14].map((badgeId) => (
                <div
                  key={badgeId}
                  className="aspect-square rounded-lg bg-gradient-to-br from-primary-500/20 to-purple-600/20 border border-primary-500/30 flex items-center justify-center"
                >
                  <Award className="w-8 h-8 text-primary-400" />
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({ icon: Icon, label, value, color }) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      className="card"
    >
      <div className="flex items-center justify-between">
        <div>
          <div className="text-gray-400 text-sm mb-1">{label}</div>
          <div className="text-2xl font-bold">{value}</div>
        </div>
        <Icon className={`w-10 h-10 ${color}`} />
      </div>
    </motion.div>
  );
}

function ChallengeCard({ id, title, difficulty, points, progress }) {
  const difficultyColor = {
    Easy: 'text-green-400',
    Medium: 'text-yellow-400',
    Hard: 'text-orange-400',
  }[difficulty];

  return (
    <Link
      to={`/challenges/${id}/solve`}
      className="block p-4 rounded-lg border border-dark-700 hover:border-dark-600 hover:bg-dark-750 transition-all"
    >
      <div className="flex items-start justify-between mb-3">
        <div>
          <h3 className="font-semibold mb-1">{title}</h3>
          <div className="flex items-center space-x-3 text-sm">
            <span className={`${difficultyColor}`}>{difficulty}</span>
            <span className="text-gray-500">•</span>
            <span className="text-gray-400">{points} XP</span>
          </div>
        </div>
        <ChevronRight className="w-5 h-5 text-gray-400" />
      </div>

      {progress > 0 && (
        <div>
          <div className="flex items-center justify-between text-xs text-gray-400 mb-2">
            <span>Progress</span>
            <span>{progress}%</span>
          </div>
          <div className="progress-bar">
            <div 
              className="progress-bar-fill"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>
      )}
    </Link>
  );
}

function ActivityItem({ type, title, time, xp }) {
  const icon = type === 'completed' ? Target : Award;
  const Icon = icon;
  const color = type === 'completed' ? 'text-green-400' : 'text-purple-400';

  return (
    <div className="flex items-center space-x-3 p-3 rounded-lg bg-dark-750">
      <Icon className={`w-5 h-5 ${color}`} />
      <div className="flex-1">
        <div className="font-medium text-sm">{title}</div>
        <div className="text-xs text-gray-400">{time}</div>
      </div>
      {xp && (
        <div className="text-sm font-semibold text-yellow-400">
          +{xp} XP
        </div>
      )}
    </div>
  );
}
