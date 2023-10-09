// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GDCProgressive is ERC20, Ownable {
    address public pool;
    address public treasury;

    uint256 public _startTime;
    uint256 public fee;

    mapping (address => bool) private _isExcludedFromFees;

    uint256 constant public TOTALSUPPLY = 1_000_000 * 10**18;
    uint256 constant public STARTMAX = TOTALSUPPLY / 1000;
    uint256 internal _addMaxWalletPerSec =
        (TOTALSUPPLY - STARTMAX) / 129600;  //increase the 99.9% remaining limit within 36 hours span

    event StartTrading(uint256 _date);
    event TotalFees(uint256 _newfee);
    event TreasuryWallet(address _lastAddress, address _newAddress);
    event ExcludedFromFee(address _account, bool _isExclude);
    
    constructor() ERC20("DOGToken", "DOG") {
        _mint(msg.sender, TOTALSUPPLY);
    }

    /// View Functions

    function isExcludedFromFees(address _account) public view returns (bool) {
        return _isExcludedFromFees[_account];
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function maxWallet(address acc) external view returns (uint256) {
        if (pool == address(0) || acc == pool || acc == owner())
            return TOTALSUPPLY;
        return
            (STARTMAX + (block.timestamp - _startTime) * _addMaxWalletPerSec);
    }

    function addMaxWalletPerSec() external view returns (uint256) {
        return _addMaxWalletPerSec;
    }

// set functions

    function start(address poolAddress) external onlyOwner {

        require(pool == address(0), "Already Started");
        pool = poolAddress;
        _isExcludedFromFees[pool] = true;
        _startTime = block.timestamp;
        emit StartTrading(block.timestamp);

    }

    function setTreasuryWallet(address _newTreasuryWallet) external onlyOwner {
        require(_newTreasuryWallet != address(0), "Marketing Wallet cannot be equal to zero address");
        treasury = _newTreasuryWallet;
        emit TreasuryWallet(treasury, _newTreasuryWallet);
    }

    function setFee(uint256 _newfee) external onlyOwner {
        require( _newfee <= 10, "Fees cannot exceed 10%");
        fee = _newfee;
        emit TotalFees(_newfee);
    }

    function excludeFromFee(address _account, bool _isExclude) external onlyOwner {
        require(_account != address(0), "Account cannot be equal to zero address");
        require(_isExcludedFromFees[_account] != _isExclude, "The user already has the status");

        _isExcludedFromFees[_account] = _isExclude;
        emit ExcludedFromFee(_account, _isExclude);
    }

// overwritten functions

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {

        require( pool != address(0) || from == owner() || to == owner(),"not started");

        require( balanceOf(to) + amount <= this.maxWallet(to), "max wallet limit");

        // Check if sender or recipient is the liquidity pool

        if(from == pool || to == pool){
            bool takefee = !_isExcludedFromFees[to] || !_isExcludedFromFees[from];
            if(takefee){
                uint256 takingFee = (amount * fee) / 100;
                amount -= takingFee;
                super._transfer(from, treasury, takingFee);
            }
        }     

        super._transfer(from, to, amount);
    }

    
}