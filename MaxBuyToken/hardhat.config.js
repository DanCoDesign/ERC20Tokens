
const { mnemonic, bscscanApiKey } = require('./secrets.json');

require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-etherscan');

const config = require('./config.json')


task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()
  for (const account of accounts) {
    console.log(account.address)
  }
})

task('balance', `Prints an account's balance`)
  .addParam('account', `The account's address`)
  .setAction(async (taskArgs, hre) => {
    const balance = await hre.ethers.provider.getBalance(taskArgs.account)
    console.log(hre.ethers.utils.formatEther(balance), 'ETH')
  })

module.exports = {
  solidity: {
    version: config.compilers.solc,
    settings: {
      optimizer: config.compilers.optimizer,
      evmVersion: config.compilers.evmVersion,
    },
  },
  defaultNetwork: 'obsidians',
  networks: {
    hardhat: {},
    obsidians: {
      url: 'http://localhost:62743',
      accounts: 'remote',
      timeout: 0,
    },

    testnet: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
      accounts: {mnemonic: mnemonic}
    },

    mainnet: {
      url: `https://bsc-dataseed.binance.org/`,
      accounts: {mnemonic: mnemonic}
    }
  },

  etherscan: {
    apiKey: bscscanApiKey,
  },
}


// npx hardhat  verify --network testnet 0xbF398