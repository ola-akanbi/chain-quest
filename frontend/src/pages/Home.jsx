import { Link } from 'react-router-dom';
import { useAccount } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { 
  Code2, 
  Trophy, 
  Users, 
  Zap, 
  Award,
  ArrowRight,
  Sparkles 
} from 'lucide-react';
import { motion } from 'framer-motion';

export default function Home() {
  const { isConnected } = useAccount();

  return (
    <div className="relative">
      {/* Hero Section */}
      <motion.section
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        className="py-20 text-center"
      >
        <div className="max-w-4xl mx-auto space-y-8">
          <motion.div
            initial={{ scale: 0.9 }}
            animate={{ scale: 1 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="inline-flex items-center space-x-2 px-4 py-2 bg-primary-500/20 rounded-full border border-primary-500/50"
          >
            <Sparkles className="w-4 h-4 text-primary-400" />
            <span className="text-sm text-primary-400 font-medium">
              Decentralized Learning Platform
            </span>
          </motion.div>

          <h1 className="text-6xl md:text-7xl font-bold">
            Master Smart Contracts
            <br />
            <span className="gradient-text">Earn On-Chain</span>
          </h1>

          <p className="text-xl text-gray-400 max-w-2xl mx-auto">
            Learn Solidity through hands-on challenges, compete with developers worldwide,
            and earn XP tokens & NFT badges for your achievements.
          </p>

          <div className="flex items-center justify-center gap-4 pt-4">
            {isConnected ? (
              <Link
                to="/dashboard"
                className="btn btn-primary px-8 py-4 text-lg flex items-center space-x-2"
              >
                <span>Go to Dashboard</span>
                <ArrowRight className="w-5 h-5" />
              </Link>
            ) : (
              <ConnectButton.Custom>
                {({ openConnectModal }) => (
                  <button
                    onClick={openConnectModal}
                    className="btn btn-primary px-8 py-4 text-lg flex items-center space-x-2"
                  >
                    <span>Connect Wallet</span>
                    <ArrowRight className="w-5 h-5" />
                  </button>
                )}
              </ConnectButton.Custom>
            )}

            <Link
              to="/challenges"
              className="btn btn-secondary px-8 py-4 text-lg"
            >
              Browse Challenges
            </Link>
          </div>
        </div>
      </motion.section>

      {/* Features */}
      <section className="py-20">
        <div className="grid md:grid-cols-3 gap-8">
          <FeatureCard
            icon={Code2}
            title="100+ Challenges"
            description="From beginner to expert - DeFi, NFTs, Security, and more"
            delay={0.3}
          />
          <FeatureCard
            icon={Trophy}
            title="Compete & Earn"
            description="Climb the leaderboard, win prizes, and earn XP tokens"
            delay={0.4}
          />
          <FeatureCard
            icon={Award}
            title="NFT Achievements"
            description="Collect unique badges as proof of your skills"
            delay={0.5}
          />
        </div>
      </section>

      {/* Stats */}
      <section className="py-20">
        <div className="glass rounded-2xl p-12">
          <div className="grid md:grid-cols-4 gap-8 text-center">
            <StatCard number="10,000+" label="Active Users" />
            <StatCard number="150+" label="Challenges" />
            <StatCard number="50K+" label="Solutions Submitted" />
            <StatCard number="$100K+" label="Prizes Distributed" />
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20">
        <h2 className="text-4xl font-bold text-center mb-12">
          How It <span className="gradient-text">Works</span>
        </h2>

        <div className="grid md:grid-cols-4 gap-6">
          <StepCard
            number="1"
            title="Connect Wallet"
            description="Mint your free Profile NFT"
          />
          <StepCard
            number="2"
            title="Choose Challenge"
            description="Pick from various categories & difficulties"
          />
          <StepCard
            number="3"
            title="Write & Submit"
            description="Code your solution and deploy"
          />
          <StepCard
            number="4"
            title="Earn Rewards"
            description="Get XP tokens & NFT badges"
          />
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 text-center">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          className="glass rounded-2xl p-12 max-w-3xl mx-auto"
        >
          <h2 className="text-4xl font-bold mb-4">
            Ready to Start Your Journey?
          </h2>
          <p className="text-gray-400 text-lg mb-8">
            Join thousands of developers learning smart contract development
          </p>
          
          {!isConnected && (
            <ConnectButton.Custom>
              {({ openConnectModal }) => (
                <button
                  onClick={openConnectModal}
                  className="btn btn-primary px-8 py-4 text-lg"
                >
                  Connect Wallet & Start Learning
                </button>
              )}
            </ConnectButton.Custom>
          )}
        </motion.div>
      </section>
    </div>
  );
}

function FeatureCard({ icon: Icon, title, description, delay }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay }}
      className="card-interactive text-center space-y-4"
    >
      <div className="inline-flex p-4 bg-primary-500/20 rounded-xl">
        <Icon className="w-8 h-8 text-primary-400" />
      </div>
      <h3 className="text-xl font-semibold">{title}</h3>
      <p className="text-gray-400">{description}</p>
    </motion.div>
  );
}

function StatCard({ number, label }) {
  return (
    <div className="space-y-2">
      <div className="text-4xl font-bold gradient-text">{number}</div>
      <div className="text-gray-400">{label}</div>
    </div>
  );
}

function StepCard({ number, title, description }) {
  return (
    <div className="relative">
      <div className="card text-center space-y-4">
        <div className="w-12 h-12 mx-auto rounded-full bg-gradient-to-br from-primary-500 to-purple-600 flex items-center justify-center text-white font-bold text-xl">
          {number}
        </div>
        <h3 className="text-lg font-semibold">{title}</h3>
        <p className="text-gray-400 text-sm">{description}</p>
      </div>
    </div>
  );
}
