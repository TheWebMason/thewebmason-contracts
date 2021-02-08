module.exports = {
  mnemonic: process.env.MNEMONIC || '',
  apiKeys: {
    etherscan: process.env.ETHERSCAN_API_KEY || '',
    mainnet: process.env.ALCHEMY_MAINNET_API_KEY || '',
    ropsten: process.env.ALCHEMY_ROPSTEN_API_KEY || '',
    kovan: process.env.ALCHEMY_KOVAN_API_KEY || '',
    rinkeby: process.env.ALCHEMY_RINKEBY_API_KEY || '',
    goerli: process.env.ALCHEMY_GOERLI_API_KEY || '',
  }
};
