import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Editor from '@monaco-editor/react';
import { Play, Save, Send, Code2, AlertCircle, CheckCircle } from 'lucide-react';
import toast from 'react-hot-toast';

const TEMPLATE_CODE = `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title YourSolution
 * @notice Write your solution here
 */
contract YourSolution {
    // Your code here
    
    constructor() {
        // Initialize your contract
    }
    
    // Add your functions
}
`;

export default function SolutionEditor() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [code, setCode] = useState(TEMPLATE_CODE);
  const [isCompiling, setIsCompiling] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [compilationResult, setCompilationResult] = useState(null);
  const [testResults, setTestResults] = useState(null);

  const handleCompile = async () => {
    setIsCompiling(true);
    toast.loading('Compiling contract...');
    
    // Simulate compilation
    setTimeout(() => {
      setIsCompiling(false);
      toast.dismiss();
      
      const success = Math.random() > 0.3; // 70% success rate for demo
      
      if (success) {
        setCompilationResult({
          success: true,
          message: 'Contract compiled successfully!',
          warnings: [],
        });
        toast.success('Compilation successful!');
      } else {
        setCompilationResult({
          success: false,
          message: 'Compilation failed',
          errors: [
            'Error: Missing semicolon at line 15',
            'Warning: Unused variable at line 22',
          ],
        });
        toast.error('Compilation failed');
      }
    }, 2000);
  };

  const handleTest = async () => {
    if (!compilationResult?.success) {
      toast.error('Please compile your contract first');
      return;
    }

    toast.loading('Running tests...');
    
    // Simulate tests
    setTimeout(() => {
      toast.dismiss();
      
      const testsPassed = Math.floor(Math.random() * 6) + 3; // 3-8 tests passed
      const totalTests = 8;
      
      setTestResults({
        passed: testsPassed,
        total: totalTests,
        tests: [
          { name: 'Contract deploys successfully', passed: true },
          { name: 'Add liquidity works correctly', passed: true },
          { name: 'Swap maintains k constant', passed: testsPassed >= 5 },
          { name: 'Fees calculated correctly', passed: testsPassed >= 6 },
          { name: 'LP tokens minted properly', passed: testsPassed >= 4 },
          { name: 'Remove liquidity works', passed: testsPassed >= 7 },
          { name: 'Handles edge cases', passed: testsPassed >= 8 },
          { name: 'Gas optimization check', passed: testsPassed >= 6 },
        ],
      });
      
      if (testsPassed === totalTests) {
        toast.success('All tests passed! 🎉');
      } else {
        toast.error(`${testsPassed}/${totalTests} tests passed`);
      }
    }, 3000);
  };

  const handleSubmit = async () => {
    if (!testResults || testResults.passed < testResults.total) {
      toast.error('Please pass all tests before submitting');
      return;
    }

    setIsSubmitting(true);
    toast.loading('Submitting solution...');
    
    // Simulate submission
    setTimeout(() => {
      setIsSubmitting(false);
      toast.dismiss();
      toast.success('Solution submitted successfully! 🎉');
      
      // Navigate to challenge detail page with success message
      setTimeout(() => {
        navigate(`/challenges/${id}`);
      }, 1500);
    }, 2000);
  };

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold mb-2">
            Challenge #{id}: <span className="gradient-text">DEX with AMM</span>
          </h1>
          <p className="text-gray-400">Write and test your smart contract solution</p>
        </div>
        
        <div className="flex items-center space-x-3">
          <button
            onClick={handleCompile}
            disabled={isCompiling}
            className="btn btn-secondary flex items-center space-x-2"
          >
            <Code2 className="w-4 h-4" />
            <span>{isCompiling ? 'Compiling...' : 'Compile'}</span>
          </button>
          
          <button
            onClick={handleTest}
            disabled={!compilationResult?.success || isCompiling}
            className="btn btn-primary flex items-center space-x-2"
          >
            <Play className="w-4 h-4" />
            <span>Run Tests</span>
          </button>
          
          <button
            onClick={handleSubmit}
            disabled={!testResults || testResults.passed < testResults.total || isSubmitting}
            className="btn btn-primary flex items-center space-x-2 bg-green-600 hover:bg-green-700"
          >
            <Send className="w-4 h-4" />
            <span>{isSubmitting ? 'Submitting...' : 'Submit'}</span>
          </button>
        </div>
      </div>

      <div className="grid lg:grid-cols-3 gap-6">
        {/* Editor */}
        <div className="lg:col-span-2">
          <div className="card p-0 overflow-hidden">
            <div className="flex items-center justify-between px-4 py-3 border-b border-dark-700">
              <span className="font-semibold">YourSolution.sol</span>
              <button className="text-sm text-gray-400 hover:text-white transition-colors">
                <Save className="w-4 h-4" />
              </button>
            </div>
            
            <Editor
              height="600px"
              defaultLanguage="sol"
              theme="vs-dark"
              value={code}
              onChange={(value) => setCode(value || '')}
              options={{
                minimap: { enabled: false },
                fontSize: 14,
                lineNumbers: 'on',
                scrollBeyondLastLine: false,
                automaticLayout: true,
                tabSize: 2,
              }}
            />
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Compilation Result */}
          {compilationResult && (
            <div className={`card ${compilationResult.success ? 'border-green-500/50' : 'border-red-500/50'}`}>
              <div className="flex items-center space-x-2 mb-3">
                {compilationResult.success ? (
                  <CheckCircle className="w-5 h-5 text-green-400" />
                ) : (
                  <AlertCircle className="w-5 h-5 text-red-400" />
                )}
                <h3 className="font-semibold">Compilation</h3>
              </div>
              
              <p className={`text-sm ${compilationResult.success ? 'text-green-400' : 'text-red-400'}`}>
                {compilationResult.message}
              </p>
              
              {compilationResult.errors && (
                <div className="mt-3 space-y-2">
                  {compilationResult.errors.map((error, index) => (
                    <div key={index} className="text-xs text-red-400 bg-red-500/10 p-2 rounded">
                      {error}
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* Test Results */}
          {testResults && (
            <div className="card">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-semibold">Test Results</h3>
                <span className={`text-lg font-bold ${testResults.passed === testResults.total ? 'text-green-400' : 'text-yellow-400'}`}>
                  {testResults.passed}/{testResults.total}
                </span>
              </div>
              
              <div className="space-y-2">
                {testResults.tests.map((test, index) => (
                  <div
                    key={index}
                    className={`flex items-center space-x-2 p-2 rounded text-sm ${
                      test.passed ? 'bg-green-500/10' : 'bg-red-500/10'
                    }`}
                  >
                    {test.passed ? (
                      <CheckCircle className="w-4 h-4 text-green-400 flex-shrink-0" />
                    ) : (
                      <AlertCircle className="w-4 h-4 text-red-400 flex-shrink-0" />
                    )}
                    <span className={test.passed ? 'text-green-400' : 'text-red-400'}>
                      {test.name}
                    </span>
                  </div>
                ))}
              </div>

              {testResults.passed === testResults.total && (
                <div className="mt-4 p-3 bg-green-500/20 rounded-lg text-center">
                  <div className="text-sm text-green-400 font-semibold">
                    🎉 All tests passed! Ready to submit!
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Challenge Info */}
          <div className="card">
            <h3 className="font-semibold mb-3">Challenge Requirements</h3>
            <ul className="space-y-2 text-sm text-gray-300">
              <li className="flex items-start space-x-2">
                <span className="text-primary-400 mt-1">•</span>
                <span>Implement add/remove liquidity</span>
              </li>
              <li className="flex items-start space-x-2">
                <span className="text-primary-400 mt-1">•</span>
                <span>Token swap functionality</span>
              </li>
              <li className="flex items-start space-x-2">
                <span className="text-primary-400 mt-1">•</span>
                <span>Use x * y = k formula</span>
              </li>
              <li className="flex items-start space-x-2">
                <span className="text-primary-400 mt-1">•</span>
                <span>0.3% trading fee</span>
              </li>
              <li className="flex items-start space-x-2">
                <span className="text-primary-400 mt-1">•</span>
                <span>LP token minting/burning</span>
              </li>
            </ul>
          </div>

          {/* Tips */}
          <div className="card bg-primary-500/10 border-primary-500/30">
            <h3 className="font-semibold mb-3 text-primary-400">💡 Tips</h3>
            <ul className="space-y-2 text-sm text-gray-300">
              <li>• Test edge cases (zero amounts, etc.)</li>
              <li>• Use SafeMath for calculations</li>
              <li>• Add reentrancy guards</li>
              <li>• Optimize gas usage</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
