//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Uniswap-V2 factory interface
interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

// Uniswap-V2 pair interface
interface IUniswapV2Pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;
}

// Uniswap-V2 router interface
interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20, Ownable {
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet;
    address public tokenPair;

    uint256 public buyFee;
    uint256 public sellFee;
    uint256 public minAmountToTakeFee;
    bool private swapping;

    IUniswapV2Router02 public routerV2;
    IUniswapV2Factory internal factoryV2;

    /// Mappgins

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;

    /// Events

    event MarketingWallet(address _lastAddress, address _newAddress);
    event TokenPair(address _lastAddress, address _newAddress);
    event UpdateMinAmountToTakeFee(
        uint256 newMinAmountToTakeFee,
        uint256 oldMinAmountToTakeFee
    );
    event TotalBuyFees(uint256 _newBuyFee);
    event TotalSellFees(uint256 _newSellFee);
    event ExcludeFromFee(address _account, bool _isExclude);
    event SendMarketing(uint256 amount);

    /// Constructor

    constructor(
        address _marketingWallet,
        uint256 _totalSupply
    ) ERC20("Fee2Marketing Token", "TKN") {
        marketingWallet = _marketingWallet;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(_uniswapV2Router.WETH(), address(this));

        routerV2 = _uniswapV2Router;
        tokenPair = _uniswapV2Pair;
        _approve(address(this), address(routerV2), type(uint256).max);
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        minAmountToTakeFee = _totalSupply / 10000; // swap and send to marketing at 0.01% of supply tokens in contract

        _isExcludedFromFees[address(routerV2)] = true;
        _isExcludedFromFees[address(factoryV2)] = true;
        _isExcludedFromFees[address(tokenPair)] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[marketingWallet] = true;

        _mint(owner(), _totalSupply);
    }

    /// View Functions

    function isExcludedFromFees(address _account) public view returns (bool) {
        return _isExcludedFromFees[_account];
    }

    /// Sets Functions

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;
    }

    function excludeFromFee(
        address _account,
        bool _isExclude
    ) external onlyOwner {
        require(
            _account != address(0),
            "Account cannot be equal to zero address"
        );
        require(
            _isExcludedFromFees[_account] != _isExclude,
            "The user already has the status to establish"
        );

        _isExcludedFromFees[_account] = _isExclude;
        emit ExcludeFromFee(_account, _isExclude);
    }

    function setTokenPair(address _newTokenPair) external onlyOwner {
        require(
            _newTokenPair != address(0),
            "Token pair cannot be equal to zero address"
        );
        emit TokenPair(tokenPair, _newTokenPair);
        tokenPair = _newTokenPair;
    }

    function setMarketingWallet(
        address _newMarketingWallet
    ) external onlyOwner {
        require(
            _newMarketingWallet != address(0),
            "Marketing Wallet cannot be equal to zero address"
        );
        emit MarketingWallet(marketingWallet, _newMarketingWallet);
        marketingWallet = _newMarketingWallet;
    }

    function setBuyFees(uint256 _newBuyFee) external onlyOwner {
        require(_newBuyFee <= 25, "Buy fees cannot exceed 25%");
        buyFee = _newBuyFee;
        emit TotalBuyFees(_newBuyFee);
    }

    function setSellFees(uint256 _newSellFee) external onlyOwner {
        require(_newSellFee <= 25, "Sell fees cannot exceed 25%");
        sellFee = _newSellFee;
        emit TotalSellFees(_newSellFee);
    }

    function updateMinAmountToTakeFee(
        uint256 _minAmountToTakeFee
    ) external onlyOwner {
        require(_minAmountToTakeFee > 0, "minAmountToTakeFee > 0");
        emit UpdateMinAmountToTakeFee(_minAmountToTakeFee, minAmountToTakeFee);
        minAmountToTakeFee = _minAmountToTakeFee;
    }

    /// Rescue Funds Functions

    function manualwithdrawBNB(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");

        (bool _status, ) = payable(marketingWallet).call{value: _amount}("");
        require(_status, "Problem on the transfer");
    }

    function withdrawTokens(
        address _token,
        address _recipient,
        uint256 _amount
    ) external onlyOwner {
        require(
            _recipient != address(0),
            "Recipient can't be the zero address"
        );
        require(
            IERC20(_token).balanceOf(address(this)) >= _amount,
            "Insufficient balance"
        );

        IERC20(_token).transfer(_recipient, _amount);
    }

    /// Overwritten Transfer Functions

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(
            balanceOf(from) >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (amount == 0) return;

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minAmountToTakeFee;

        if (
            !swapping &&
            overMinimumTokenBalance &&
            automatedMarketMakerPairs[to]
        ) // if greater than min tokens in contract balance, swap and send to marketing wallet
        {
            swapping = true;
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = routerV2.WETH();

            routerV2.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0, // accept any amount of BaseToken
                path,
                address(this),
                block.timestamp
            );
            uint256 newBalance = address(this).balance;
            sendToMarketing(newBalance);

            swapping = false;
        }

        uint256 fee;

        if (!_isExcludedFromFees[from] || !_isExcludedFromFees[to]) {
            // Buy
            if (from == tokenPair) {
                fee = (amount * buyFee) / 100;
                super._transfer(from, address(this), fee);
            }
            // Sell
            else if (to == tokenPair) {
                fee = (amount * sellFee) / 100;

                super._transfer(from, address(this), fee);
            }
            amount -= fee;
        }

        super._transfer(from, to, amount);
    }

    function sendToMarketing(uint256 amount) private {
        (bool _status, ) = payable(marketingWallet).call{value: amount}("");

        if (_status) {
            emit SendMarketing(amount);
        }
    }

    receive() external payable {}
}
