import { Link } from 'react-router-dom';
import { useAccount } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Code2, Trophy, BookOpen, User } from 'lucide-react';

export default function Navbar() {
  const { isConnected } = useAccount();

  return (
    <nav className="glass sticky top-0 z-50 border-b border-dark-700">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center space-x-2 group">
            <Code2 className="w-8 h-8 text-primary-500 group-hover:rotate-12 transition-transform" />
            <span className="text-xl font-bold gradient-text">ChainQuest</span>
          </Link>

          {/* Navigation Links */}
          {isConnected && (
            <div className="hidden md:flex items-center space-x-6">
              <NavLink to="/dashboard" icon={BookOpen}>
                Dashboard
              </NavLink>
              <NavLink to="/challenges" icon={Code2}>
                Challenges
              </NavLink>
              <NavLink to="/leaderboard" icon={Trophy}>
                Leaderboard
              </NavLink>
              <NavLink to="/profile" icon={User}>
                Profile
              </NavLink>
            </div>
          )}

          {/* Connect Button */}
          <div className="flex items-center space-x-4">
            <ConnectButton
              chainStatus="icon"
              showBalance={false}
              accountStatus={{
                smallScreen: 'avatar',
                largeScreen: 'full',
              }}
            />
          </div>
        </div>
      </div>
    </nav>
  );
}

function NavLink({ to, icon: Icon, children }) {
  return (
    <Link
      to={to}
      className="flex items-center space-x-2 px-3 py-2 rounded-lg hover:bg-dark-800 transition-colors group"
    >
      <Icon className="w-4 h-4 text-gray-400 group-hover:text-primary-500 transition-colors" />
      <span className="text-gray-300 group-hover:text-white transition-colors">
        {children}
      </span>
    </Link>
  );
}
