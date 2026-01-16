# ChainQuest

ChainQuest is a decentralized platform designed to gamify learning and skill development using blockchain technology. It leverages smart contracts to manage challenges, track user progress, distribute rewards, and maintain a transparent leaderboard system. The project consists of Ethereum smart contracts and a modern frontend interface.

## Features

- **Challenge Registry:** Register, manage, and browse coding or learning challenges.
- **Solution Submission & Validation:** Users submit solutions, which are validated on-chain.
- **Experience Tokens:** Earn tokens for completing challenges and progressing through the platform.
- **Achievement Badges:** Unlock badges for milestones and achievements.
- **Leaderboard:** Transparent, real-time ranking of users based on performance.
- **Reward Distribution:** Automated, fair distribution of rewards to top performers.
- **User Profiles:** Track individual progress, badges, and statistics.

## Tech Stack

- **Smart Contracts:** Solidity, Hardhat
- **Frontend:** React, Vite, Tailwind CSS, Wagmi
- **Blockchain:** Ethereum-compatible networks

## Project Structure

```
contracts/         # Solidity smart contracts and Hardhat config
frontend/          # React frontend application
README.md          # Project documentation
package.json       # Root dependencies and scripts
```

## Getting Started

### Prerequisites

- Node.js (v16+ recommended)
- npm or yarn
- Hardhat (for contract development)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ola-akanbi/chain-quest.git
   cd chain-quest
   ```

2. **Install dependencies:**
   ```bash
   # For contracts
   cd contracts
   npm install
   # For frontend
   cd ../frontend
   npm install
   ```

### Running the Project

#### Smart Contracts

1. **Compile contracts:**
   ```bash
   cd contracts
   npx hardhat compile
   ```
2. **Run local blockchain (optional):**
   ```bash
   npx hardhat node
   ```
3. **Deploy contracts:**
   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```

#### Frontend

1. **Start the development server:**
   ```bash
   cd frontend
   npm run dev
   ```
2. **Open in browser:**
   Visit [http://localhost:5173](http://localhost:5173) (or the port shown in your terminal).

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements, bug fixes, or new features. Make sure to follow the code of conduct and contribution guidelines.

## License

This project is licensed under the MIT License.

## Contact

- **Author:** Olamilekan Akanbi
- **GitHub:** [ola-akanbi](https://github.com/ola-akanbi)

For questions or support, please open an issue in the repository.
