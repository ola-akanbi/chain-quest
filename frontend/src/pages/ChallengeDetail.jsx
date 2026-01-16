import { useParams, Link } from 'react-router-dom';
import { Code2, Award, Users, Clock, ChevronRight, CheckCircle } from 'lucide-react';
import { motion } from 'framer-motion';
import { DIFFICULTY_LABELS, CATEGORY_LABELS } from '../config/constants';

export default function ChallengeDetail() {
  const { id } = useParams();

  // Mock data - in production, fetch from contract
  const challenge = {
    id,
    title: 'Build a DEX with AMM',
    description: 'Create a decentralized exchange with an automated market maker using the constant product formula (x * y = k).',
    difficulty: 2,
    category: 0,
    points: 800,
    requiredLevel: 6,
    completions: 320,
    averageTime: '4.5 hours',
    fullDescription: `
## Objective
Build a fully functional decentralized exchange (DEX) with an automated market maker (AMM) based on the constant product formula.

## Requirements
1. **Liquidity Pool**: Implement functions to add and remove liquidity
2. **Token Swaps**: Enable users to swap between two ERC20 tokens
3. **Price Calculation**: Use the x * y = k formula for pricing
4. **Fees**: Implement a 0.3% trading fee
5. **LP Tokens**: Mint/burn LP tokens for liquidity providers

## Test Cases
- Adding liquidity should mint LP tokens proportionally
- Swaps should maintain the k constant
- Fees should be correctly collected
- Removing liquidity should burn LP tokens

## Tips
- Consider slippage protection
- Handle edge cases (zero liquidity, etc.)
- Gas optimization is important
    `,
    testCriteria: [
      'Contract compiles successfully',
      'Add liquidity function works correctly',
      'Swap function maintains k constant',
      'Fees are calculated correctly',
      'LP tokens are minted/burned properly',
      'Passes all security checks',
    ],
    resources: [
      { title: 'Uniswap V2 Whitepaper', url: 'https://uniswap.org/whitepaper.pdf' },
      { title: 'AMM Guide', url: '#' },
      { title: 'Solidity Best Practices', url: '#' },
    ],
  };

  return (
    <div className="max-w-5xl mx-auto space-y-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <div className="flex items-center space-x-2 text-sm text-gray-400 mb-4">
          <Link to="/challenges" className="hover:text-primary-400">
            Challenges
          </Link>
          <ChevronRight className="w-4 h-4" />
          <span>{challenge.title}</span>
        </div>

        <h1 className="text-4xl font-bold mb-4">{challenge.title}</h1>
        
        <div className="flex flex-wrap items-center gap-4 text-sm">
          <span className={`badge difficulty-${DIFFICULTY_LABELS[challenge.difficulty].toLowerCase()}`}>
            {DIFFICULTY_LABELS[challenge.difficulty]}
          </span>
          <span className="badge bg-dark-700">
            {CATEGORY_LABELS[challenge.category]}
          </span>
          <span className="text-yellow-400 font-semibold">
            {challenge.points} XP
          </span>
          <span className="text-gray-400 flex items-center space-x-1">
            <Users className="w-4 h-4" />
            <span>{challenge.completions} solved</span>
          </span>
          <span className="text-gray-400 flex items-center space-x-1">
            <Clock className="w-4 h-4" />
            <span>Avg: {challenge.averageTime}</span>
          </span>
        </div>
      </motion.div>

      {/* Main Content */}
      <div className="grid lg:grid-cols-3 gap-8">
        {/* Description */}
        <div className="lg:col-span-2 space-y-6">
          <section className="card">
            <h2 className="text-2xl font-bold mb-4">Description</h2>
            <p className="text-gray-300 leading-relaxed">{challenge.description}</p>
          </section>

          <section className="card">
            <h2 className="text-2xl font-bold mb-4">Full Challenge</h2>
            <div className="prose prose-invert max-w-none">
              <div className="text-gray-300 whitespace-pre-line leading-relaxed">
                {challenge.fullDescription}
              </div>
            </div>
          </section>

          <section className="card">
            <h2 className="text-2xl font-bold mb-4">Test Criteria</h2>
            <div className="space-y-3">
              {challenge.testCriteria.map((criterion, index) => (
                <div key={index} className="flex items-start space-x-3">
                  <CheckCircle className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
                  <span className="text-gray-300">{criterion}</span>
                </div>
              ))}
            </div>
          </section>

          <section className="card">
            <h2 className="text-2xl font-bold mb-4">Resources</h2>
            <div className="space-y-2">
              {challenge.resources.map((resource, index) => (
                <a
                  key={index}
                  href={resource.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="block p-3 rounded-lg bg-dark-750 hover:bg-dark-700 transition-colors"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-primary-400">{resource.title}</span>
                    <ChevronRight className="w-4 h-4 text-gray-400" />
                  </div>
                </a>
              ))}
            </div>
          </section>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Action Card */}
          <div className="card sticky top-20">
            <div className="space-y-4">
              <div className="text-center">
                <div className="text-3xl font-bold text-yellow-400 mb-2">
                  {challenge.points} XP
                </div>
                <p className="text-sm text-gray-400">
                  Earn XP and badges by solving this challenge
                </p>
              </div>

              <Link
                to={`/challenges/${id}/solve`}
                className="block w-full btn btn-primary py-4 text-lg"
              >
                Start Challenge
              </Link>

              <div className="pt-4 border-t border-dark-700 space-y-3 text-sm">
                <div className="flex items-center justify-between">
                  <span className="text-gray-400">Required Level</span>
                  <span className="font-semibold">{challenge.requiredLevel}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-gray-400">Completions</span>
                  <span className="font-semibold">{challenge.completions}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-gray-400">Average Time</span>
                  <span className="font-semibold">{challenge.averageTime}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Potential Badges */}
          <div className="card">
            <h3 className="font-semibold mb-4">Potential Badges</h3>
            <div className="grid grid-cols-2 gap-3">
              <BadgePreview name="Speed Demon" />
              <BadgePreview name="Perfect Score" />
              <BadgePreview name="Gas Optimizer" />
              <BadgePreview name="DeFi Master" />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function BadgePreview({ name }) {
  return (
    <div className="aspect-square rounded-lg bg-gradient-to-br from-primary-500/20 to-purple-600/20 border border-primary-500/30 p-3 flex flex-col items-center justify-center text-center">
      <Award className="w-8 h-8 text-primary-400 mb-2" />
      <span className="text-xs text-gray-300">{name}</span>
    </div>
  );
}
