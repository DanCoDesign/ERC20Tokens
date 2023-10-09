# Open Zeppelin Contracts

Using Uniswap Interfaces for a simple ERC20 Token. Max buy is progressively increased in time (36hours).

__This one is my original work__

## Deploy
- npm install
- build: "hardhat compile --config hardhat.config.js"
- deploy: "hardhat run scripts/deploy.js"

## Smart Contracts

- **contracts/GDCProgressive.sol**:
    - Imports 2 contracts:
        - import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
        - import "@openzeppelin/contracts/access/Ownable.sol";
    - Steps:
        - Set Initial Fees with setFee() function
        - Set Treasury wallet. This will collect taxes for buy/sell
        - Start Trading with pool address as argument

## Reference

- Testnet: https://testnet.bscscan.com/address/0x813480ce91ecb3bff153914fb4e870390774994c
- 
