import { useParams } from 'react-router-dom';
import { useAccount } from 'wagmi';
import { 
  Award, 
  TrendingUp, 
  Target, 
  Zap,
  Calendar,
  Trophy
} from 'lucide-react';
import { motion } from 'framer-motion';

export default function Profile() {
  const { address: paramAddress } = useParams();
  const { address: connectedAddress } = useAccount();
  
  const address = paramAddress || connectedAddress;
  const isOwnProfile = !paramAddress || paramAddress === connectedAddress;

  // Mock data
  const profile = {
    address,
    level: 7,
    xp: 14250,
    totalChallenges: 45,
    completedChallenges: 18,
    badges: [
      { id: 1, name: 'First Blood', rarity: 'common' },
      { id: 2, name: 'Rising Star', rarity: 'rare' },
      { id: 4, name: 'Speed Demon', rarity: 'epic' },
      { id: 12, name: 'Gas Optimizer', rarity: 'legendary' },
      { id: 14, name: 'Perfect Score', rarity: 'rare' },
      { id: 6, name: 'Consistent', rarity: 'rare' },
    ],
    streak: 12,
    rank: 127,
    joinedDate: '2024-01-15',
    recentActivity: [
      { type: 'completed', challenge: 'NFT Marketplace', xp: 500, date: '2024-01-05' },
      { type: 'badge', name: 'Gas Optimizer', date: '2024-01-04' },
      { type: 'completed', challenge: 'ERC20 Token', xp: 250, date: '2024-01-03' },
    ],
  };

  const xpToNextLevel = 16000;
  const xpProgress = (profile.xp / xpToNextLevel) * 100;
  const completionRate = ((profile.completedChallenges / profile.totalChallenges) * 100).toFixed(1);

  return (
    <div className="max-w-6xl mx-auto space-y-8">
      {/* Profile Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="card"
      >
        <div className="flex flex-col md:flex-row items-start md:items-center gap-6">
          {/* Avatar */}
          <div className="relative">
            <div className="w-32 h-32 rounded-2xl bg-gradient-to-br from-primary-500 to-purple-600 flex items-center justify-center text-6xl">
              👨‍💻
            </div>
            <div className="absolute -bottom-2 -right-2 level-badge text-2xl">
              {profile.level}
            </div>
          </div>

          {/* Info */}
          <div className="flex-1 space-y-4">
            <div>
              <h1 className="text-3xl font-bold mb-2">
                {isOwnProfile ? 'Your Profile' : 'Developer Profile'}
              </h1>
              <p className="font-mono text-gray-400">{profile.address}</p>
            </div>

            {/* Level Progress */}
            <div>
              <div className="flex items-center justify-between text-sm mb-2">
                <span className="text-gray-400">
                  Level {profile.level} - {profile.xp.toLocaleString()} XP
                </span>
                <span className="text-gray-400">
                  {(xpToNextLevel - profile.xp).toLocaleString()} XP to Level {profile.level + 1}
                </span>
              </div>
              <div className="progress-bar h-3">
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: `${xpProgress}%` }}
                  transition={{ duration: 1, delay: 0.3 }}
                  className="progress-bar-fill"
                />
              </div>
            </div>

            {/* Quick Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <QuickStat icon={Trophy} label="Rank" value={`#${profile.rank}`} />
              <QuickStat icon={Target} label="Completed" value={profile.completedChallenges} />
              <QuickStat icon={Zap} label="Streak" value={`${profile.streak} days`} />
              <QuickStat icon={Award} label="Badges" value={profile.badges.length} />
            </div>
          </div>
        </div>
      </motion.div>

      {/* Two Column Layout */}
      <div className="grid lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-8">
          {/* Stats Overview */}
          <section className="card">
            <h2 className="text-2xl font-bold mb-6">Statistics</h2>
            
            <div className="grid md:grid-cols-3 gap-6">
              <StatCard
                label="Total XP"
                value={profile.xp.toLocaleString()}
                color="text-yellow-400"
                icon="⚡"
              />
              <StatCard
                label="Completion Rate"
                value={`${completionRate}%`}
                color="text-green-400"
                icon="🎯"
              />
              <StatCard
                label="Challenges"
                value={`${profile.completedChallenges}/${profile.totalChallenges}`}
                color="text-blue-400"
                icon="📝"
              />
            </div>
          </section>

          {/* Recent Activity */}
          <section className="card">
            <h2 className="text-2xl font-bold mb-6">Recent Activity</h2>
            
            <div className="space-y-4">
              {profile.recentActivity.map((activity, index) => (
                <ActivityItem key={index} activity={activity} />
              ))}
            </div>
          </section>

          {/* Badges Collection */}
          <section className="card">
            <h2 className="text-2xl font-bold mb-6">
              Badge Collection ({profile.badges.length})
            </h2>
            
            <div className="grid grid-cols-3 md:grid-cols-4 gap-4">
              {profile.badges.map((badge) => (
                <BadgeCard key={badge.id} badge={badge} />
              ))}
            </div>
          </section>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Profile Info */}
          <div className="card">
            <h3 className="font-semibold mb-4">Profile Info</h3>
            
            <div className="space-y-3 text-sm">
              <InfoRow
                icon={Calendar}
                label="Member Since"
                value={new Date(profile.joinedDate).toLocaleDateString()}
              />
              <InfoRow
                icon={TrendingUp}
                label="Current Level"
                value={profile.level}
              />
              <InfoRow
                icon={Trophy}
                label="Global Rank"
                value={`#${profile.rank}`}
              />
              <InfoRow
                icon={Zap}
                label="Current Streak"
                value={`${profile.streak} days`}
              />
            </div>
          </div>

          {/* Achievements Progress */}
          <div className="card">
            <h3 className="font-semibold mb-4">Next Achievements</h3>
            
            <div className="space-y-4">
              <AchievementProgress
                name="Streak Master"
                progress={profile.streak}
                target={30}
                icon="🔥"
              />
              <AchievementProgress
                name="Elite Coder"
                progress={profile.level}
                target={10}
                icon="🎓"
              />
              <AchievementProgress
                name="Challenge Hunter"
                progress={profile.completedChallenges}
                target={50}
                icon="🎯"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function QuickStat({ icon: Icon, label, value }) {
  return (
    <div className="flex items-center space-x-3 p-3 rounded-lg bg-dark-750">
      <Icon className="w-5 h-5 text-primary-400" />
      <div>
        <div className="text-xs text-gray-400">{label}</div>
        <div className="font-semibold">{value}</div>
      </div>
    </div>
  );
}

function StatCard({ label, value, color, icon }) {
  return (
    <div className="text-center p-4 rounded-lg bg-dark-750">
      <div className="text-3xl mb-2">{icon}</div>
      <div className={`text-2xl font-bold ${color} mb-1`}>{value}</div>
      <div className="text-sm text-gray-400">{label}</div>
    </div>
  );
}

function ActivityItem({ activity }) {
  if (activity.type === 'completed') {
    return (
      <div className="flex items-center justify-between p-4 rounded-lg bg-dark-750">
        <div className="flex items-center space-x-3">
          <Target className="w-5 h-5 text-green-400" />
          <div>
            <div className="font-medium">Completed: {activity.challenge}</div>
            <div className="text-sm text-gray-400">{activity.date}</div>
          </div>
        </div>
        <div className="text-yellow-400 font-semibold">
          +{activity.xp} XP
        </div>
      </div>
    );
  }

  return (
    <div className="flex items-center justify-between p-4 rounded-lg bg-dark-750">
      <div className="flex items-center space-x-3">
        <Award className="w-5 h-5 text-purple-400" />
        <div>
          <div className="font-medium">Earned: {activity.name}</div>
          <div className="text-sm text-gray-400">{activity.date}</div>
        </div>
      </div>
    </div>
  );
}

function BadgeCard({ badge }) {
  const rarityColors = {
    common: 'from-gray-500 to-gray-600',
    rare: 'from-blue-500 to-blue-600',
    epic: 'from-purple-500 to-purple-600',
    legendary: 'from-yellow-500 to-orange-600',
  };

  return (
    <div className="group cursor-pointer">
      <div className={`aspect-square rounded-xl bg-gradient-to-br ${rarityColors[badge.rarity]} p-4 flex items-center justify-center group-hover:scale-110 transition-transform`}>
        <Award className="w-12 h-12 text-white" />
      </div>
      <div className="text-center mt-2">
        <div className="text-xs font-medium line-clamp-2">{badge.name}</div>
        <div className="text-xs text-gray-500 capitalize">{badge.rarity}</div>
      </div>
    </div>
  );
}

function InfoRow({ icon: Icon, label, value }) {
  return (
    <div className="flex items-center justify-between">
      <div className="flex items-center space-x-2 text-gray-400">
        <Icon className="w-4 h-4" />
        <span>{label}</span>
      </div>
      <span className="font-semibold">{value}</span>
    </div>
  );
}

function AchievementProgress({ name, progress, target, icon }) {
  const percentage = (progress / target) * 100;

  return (
    <div>
      <div className="flex items-center justify-between text-sm mb-2">
        <div className="flex items-center space-x-2">
          <span>{icon}</span>
          <span className="font-medium">{name}</span>
        </div>
        <span className="text-gray-400">{progress}/{target}</span>
      </div>
      <div className="progress-bar">
        <div 
          className="progress-bar-fill"
          style={{ width: `${percentage}%` }}
        />
      </div>
    </div>
  );
}
