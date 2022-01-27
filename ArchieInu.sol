// SPDX-License-Identifier: Unlicensed

 pragma solidity 0.8.9;
 
 interface IERC20 {
 
     function totalSupply() external view returns (uint256);
 
     function balanceOf(address account) external view returns (uint256);

     function transfer(address recipient, uint256 amount) external returns (bool);
 
     function allowance(address owner, address spender) external view returns (uint256);

     function approve(address spender, uint256 amount) external returns (bool);

     function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     event Transfer(address indexed from, address indexed to, uint256 value);

     event Approval(address indexed owner, address indexed spender, uint256 value);
 }
  
 library SafeMath {

     function add(uint256 a, uint256 b) internal pure returns (uint256) {
         uint256 c = a + b;
         require(c >= a, "SafeMath: addition overflow"); 
         return c;
     }

     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
         return sub(a, b, "SafeMath: subtraction overflow");
     }

     function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         require(b <= a, errorMessage);
         uint256 c = a - b; 
         return c;
     }

     function mul(uint256 a, uint256 b) internal pure returns (uint256) {

         if (a == 0) {
             return 0;
         }

         uint256 c = a * b;
         require(c / a == b, "SafeMath: multiplication overflow");
         return c;
     }

     function div(uint256 a, uint256 b) internal pure returns (uint256) {
         return div(a, b, "SafeMath: division by zero");
     }

     function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         require(b > 0, errorMessage);
         uint256 c = a / b;
 
         return c;
     }

     function mod(uint256 a, uint256 b) internal pure returns (uint256) {
         return mod(a, b, "SafeMath: modulo by zero");
     }

     function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         require(b != 0, errorMessage);
         return a % b;
     }
 }
 
 abstract contract Context {
     function _msgSender() internal view virtual returns (address payable) {
         return msg.sender;
     }
 
     function _msgData() internal view virtual returns (bytes memory) {
         this; 
         return msg.data;
     }
 }

 library Address {

     function isContract(address account) internal view returns (bool) {

         bytes32 codehash;
         bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         assembly { codehash := extcodehash(account) }
         return (codehash != accountHash && codehash != 0x0);
     }

     function sendValue(address payable recipient, uint256 amount) internal {
         require(address(this).balance >= amount, "Address: insufficient balance");
 
         (bool success, ) = recipient.call{ value: amount }("");
         require(success, "Address: unable to send value, recipient may have reverted");
     }

     function functionCall(address target, bytes memory data) internal returns (bytes memory) {
       return functionCall(target, data, "Address: low-level call failed");
     }

     function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
         return _functionCallWithValue(target, data, 0, errorMessage);
     }
 
     function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
         return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
     }

     function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
         require(address(this).balance >= value, "Address: insufficient balance for call");
         return _functionCallWithValue(target, data, value, errorMessage);
     }
 
     function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
         require(isContract(target), "Address: call to non-contract");
 
         // solhint-disable-next-line avoid-low-level-calls
         (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
         if (success) {
             return returndata;
         } else {
             // Look for revert reason and bubble it up if present
             if (returndata.length > 0) {
                 // The easiest way to bubble the revert reason is using memory via assembly
 
                 // solhint-disable-next-line no-inline-assembly
                 assembly {
                     let returndata_size := mload(returndata)
                     revert(add(32, returndata), returndata_size)
                 }
             } else {
                 revert(errorMessage);
             }
         }
     }
 }

 contract Ownable is Context {
     address private _owner;
     address private _previousOwner;
     uint256 private _lockTime;
 
     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
     /**
      * @dev Initializes the contract setting the deployer as the initial owner.
      */
     constructor () internal {
         address msgSender = _msgSender();
         _owner = msgSender;
         emit OwnershipTransferred(address(0), msgSender);
     }
 
     /**
      * @dev Returns the address of the current owner.
      */
     function owner() public view returns (address) {
         return _owner;
     }
 
     /**
      * @dev Throws if called by any account other than the owner.
      */
     modifier onlyOwner() {
         require(_owner == _msgSender(), "Ownable: caller is not the owner");
         _;
     }
 
      /**
      * @dev Leaves the contract without owner. It will not be possible to call
      * `onlyOwner` functions anymore. Can only be called by the current owner.
      *
      * NOTE: Renouncing ownership will leave the contract without an owner,
      * thereby removing any functionality that is only available to the owner.
      */
     function renounceOwnership() public virtual onlyOwner {
         emit OwnershipTransferred(_owner, address(0));
         _owner = address(0);
     }
 
     /**
      * @dev Transfers ownership of the contract to a new account (`newOwner`).
      * Can only be called by the current owner.
      */
     function transferOwnership(address newOwner) public virtual onlyOwner {
         require(newOwner != address(0), "Ownable: new owner is the zero address");
         emit OwnershipTransferred(_owner, newOwner);
         _owner = newOwner;
     }
 
     function geUnlockTime() public view returns (uint256) {
         return _lockTime;
     }
 
     //Locks the contract for owner for the amount of time provided
     function lock(uint256 time) public virtual onlyOwner {
         _previousOwner = _owner;
         _owner = address(0);
         _lockTime = now + time;
         emit OwnershipTransferred(_owner, address(0));
     }
     
     //Unlocks the contract for owner when _lockTime is exceeds
     function unlock() public virtual {
         require(_previousOwner == msg.sender, "You don't have permission to unlock");
         require(now > _lockTime , "Contract is locked until 7 days");
         emit OwnershipTransferred(_owner, _previousOwner);
         _owner = _previousOwner;
     }
 }
 
 interface IUniswapV2Factory {
     event PairCreated(address indexed token0, address indexed token1, address pair, uint);
 
     function feeTo() external view returns (address);
     function feeToSetter() external view returns (address);
 
     function getPair(address tokenA, address tokenB) external view returns (address pair);
     function allPairs(uint) external view returns (address pair);
     function allPairsLength() external view returns (uint);
 
     function createPair(address tokenA, address tokenB) external returns (address pair);
 
     function setFeeTo(address) external;
     function setFeeToSetter(address) external;
 }
 
 interface IUniswapV2Pair {
     event Approval(address indexed owner, address indexed spender, uint value);
     event Transfer(address indexed from, address indexed to, uint value);
 
     function name() external pure returns (string memory);
     function symbol() external pure returns (string memory);
     function decimals() external pure returns (uint8);
     function totalSupply() external view returns (uint);
     function balanceOf(address owner) external view returns (uint);
     function allowance(address owner, address spender) external view returns (uint);
 
     function approve(address spender, uint value) external returns (bool);
     function transfer(address to, uint value) external returns (bool);
     function transferFrom(address from, address to, uint value) external returns (bool);
 
     function DOMAIN_SEPARATOR() external view returns (bytes32);
     function PERMIT_TYPEHASH() external pure returns (bytes32);
     function nonces(address owner) external view returns (uint);
 
     function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
 
     event Mint(address indexed sender, uint amount0, uint amount1);
     event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
     event Swap(
         address indexed sender,
         uint amount0In,
         uint amount1In,
         uint amount0Out,
         uint amount1Out,
         address indexed to
     );
     event Sync(uint112 reserve0, uint112 reserve1);
 
     function MINIMUM_LIQUIDITY() external pure returns (uint);
     function factory() external view returns (address);
     function token0() external view returns (address);
     function token1() external view returns (address);
     function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
     function price0CumulativeLast() external view returns (uint);
     function price1CumulativeLast() external view returns (uint);
     function kLast() external view returns (uint);
 
     function mint(address to) external returns (uint liquidity);
     function burn(address to) external returns (uint amount0, uint amount1);
     function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
     function skim(address to) external;
     function sync() external;
 
     function initialize(address, address) external;
 }
 
 interface IUniswapV2Router01 {
     function factory() external pure returns (address);
     function WETH() external pure returns (address);
 
     function addLiquidity(
         address tokenA,
         address tokenB,
         uint amountADesired,
         uint amountBDesired,
         uint amountAMin,
         uint amountBMin,
         address to,
         uint deadline
     ) external returns (uint amountA, uint amountB, uint liquidity);
     function addLiquidityETH(
         address token,
         uint amountTokenDesired,
         uint amountTokenMin,
         uint amountETHMin,
         address to,
         uint deadline
     ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function removeLiquidity(
         address tokenA,
         address tokenB,
         uint liquidity,
         uint amountAMin,
         uint amountBMin,
         address to,
         uint deadline
     ) external returns (uint amountA, uint amountB);
     function removeLiquidityETH(
         address token,
         uint liquidity,
         uint amountTokenMin,
         uint amountETHMin,
         address to,
         uint deadline
     ) external returns (uint amountToken, uint amountETH);
     function removeLiquidityWithPermit(
         address tokenA,
         address tokenB,
         uint liquidity,
         uint amountAMin,
         uint amountBMin,
         address to,
         uint deadline,
         bool approveMax, uint8 v, bytes32 r, bytes32 s
     ) external returns (uint amountA, uint amountB);
     function removeLiquidityETHWithPermit(
         address token,
         uint liquidity,
         uint amountTokenMin,
         uint amountETHMin,
         address to,
         uint deadline,
         bool approveMax, uint8 v, bytes32 r, bytes32 s
     ) external returns (uint amountToken, uint amountETH);
     function swapExactTokensForTokens(
         uint amountIn,
         uint amountOutMin,
         address[] calldata path,
         address to,
         uint deadline
     ) external returns (uint[] memory amounts);
     function swapTokensForExactTokens(
         uint amountOut,
         uint amountInMax,
         address[] calldata path,
         address to,
         uint deadline
     ) external returns (uint[] memory amounts);
     function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
         external
         payable
         returns (uint[] memory amounts);
     function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
         external
         returns (uint[] memory amounts);
     function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
         external
         returns (uint[] memory amounts);
     function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
         external
         payable
         returns (uint[] memory amounts);
 
     function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
     function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
     function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
     function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
     function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
 }
 
 interface IUniswapV2Router02 is IUniswapV2Router01 {
     function removeLiquidityETHSupportingFeeOnTransferTokens(
         address token,
         uint liquidity,
         uint amountTokenMin,
         uint amountETHMin,
         address to,
         uint deadline
     ) external returns (uint amountETH);
     function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
         address token,
         uint liquidity,
         uint amountTokenMin,
         uint amountETHMin,
         address to,
         uint deadline,
         bool approveMax, uint8 v, bytes32 r, bytes32 s
     ) external returns (uint amountETH);
 
     function swapExactTokensForTokensSupportingFeeOnTransferTokens(
         uint amountIn,
         uint amountOutMin,
         address[] calldata path,
         address to,
         uint deadline
     ) external;
     function swapExactETHForTokensSupportingFeeOnTransferTokens(
         uint amountOutMin,
         address[] calldata path,
         address to,
         uint deadline
     ) external payable;
     function swapExactTokensForETHSupportingFeeOnTransferTokens(
         uint amountIn,
         uint amountOutMin,
         address[] calldata path,
         address to,
         uint deadline
     ) external;
 }
 
 
 contract ArhcieInu is Context, IERC20, Ownable {
     using SafeMath for uint256;
     using Address for address;

     struct privateSaleHolerData {
        bool _isprivateSale;
        uint256 privateSaleTimeStamp;
        uint256 amount;
     }

     struct transactionDetailData {
         uint256 amount;
         uint256 timeStamp;
     }
 
     mapping (address => uint256) private _rOwned;
     mapping (address => uint256) private _tOwned;
     mapping (address => mapping (address => uint256)) private _allowances; 
     mapping (address => bool) private _isExcludedFromFee;
     mapping (address => bool) private _isExcluded;
     mapping (address => bool) private _isBlackList;
     mapping (address => privateSaleHolderData) private privateSaleData;
     mapping (address => transactionDetailData) private transactionData;
     mapping (address => bool) public automatedMarketMakerPairs;

     address[] private _excluded;

     bool _onPrivateSale = false;
     bool _tradingActive = true;
     bool inSwapAndLiquify;
     bool public swapAndLiquifyEnabled = true;
    
     uint256 private constant MAX = ~uint256(0);
     uint256 private _tTotal = 10000000000000 * 10**6 * 10**18;
     uint256 private _rTotal = (MAX - (MAX % _tTotal));
     uint256 private _tFeeTotal;
 
     string private _name = "Archie Inu";
     string private _symbol = "Archie";
     uint8 private _decimals = 18;
     
     uint256 public _reflectionTax;
     uint256 public _reflectionBuyTax = 5;
     uint256 public _reflectionSellTax = 5;

     uint256 public _liquidityTax;
     uint256 public _liquidityBuyTax = 5;
     uint256 public _liquiditySellTax = 7;

     uint256 public _marketingTax;
     uint256 public _marketingBuyTax = 5;
     uint256 public _marketingSellTax = 8;
     

 
     IUniswapV2Router02 public  uniswapV2Router;
     address public uniswapV2Pair;

     address public _owenerAddress = 0x233C59Ccf9cEBDeF7f80f2e04Ff2967D072aC5;
     address public _marketingAddress = 0xFe0DadD607aB0d5C5294Aa419911897E4C9a2313;
     address public _deadAdderess = 0x000000000000000000000000000000000000dead;


     uint256 private numTokensSellToAddToLiquidity = _tTotal / 1000;
     uint256 public _maxwalletamount = _tTotal / 200;
     uint256 public _privateSaleTimeLimit = 90 days;//???
     uint256 public _dailyTimeLimit = 24 hours;//????
     uint256 public _dailymaxTxAmount = 25;
     uint256 public _maxTxAmount = 3;
     
     event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
     event SwapAndLiquifyEnabledUpdated(bool enabled);
     event SwapAndLiquify(
         uint256 tokensSwapped,
         uint256 ethReceived,
         uint256 tokensIntoLiqudity
     );
     
     modifier lockTheSwap {
         inSwapAndLiquify = true;
         _;
         inSwapAndLiquify = false;
     }
     
     constructor () public {
         _rOwned[_owenerAddress] = _rTotal;
         
         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);//????????????

         uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
             .createPair(address(this), _uniswapV2Router.WETH());

         uniswapV2Router = _uniswapV2Router;

         _isExcludedFromFee[_owenerAddress] = true;
         _isExcludedFromFee[address(this)] = true;

         _isExcluded[_deadAdderess] = true;
         _isExcluded[uniswapV2Pair] = true;
         
         emit Transfer(address(0), _msgSender(), _tTotal);
     }

     // ERC-20 standard functions
 
     function name() public view returns (string memory) {
         return _name;
     }
 
     function symbol() public view returns (string memory) {
         return _symbol;
     }
 
     function decimals() public view returns (uint8) {
         return _decimals;
     }
 
     function totalSupply() public view override returns (uint256) {
         return _tTotal;
     }
 
     function balanceOf(address account) public view override returns (uint256) {
         if (_isExcluded[account]) return _tOwned[account];
         return tokenFromReflection(_rOwned[account]);
     }
 
     function transfer(address recipient, uint256 amount) public override returns (bool) {
         _transfer(_msgSender(), recipient, amount);
         return true;
     }
 
     function allowance(address owner, address spender) public view override returns (uint256) {
         return _allowances[owner][spender];
     }
 
     function approve(address spender, uint256 amount) public override returns (bool) {
         _approve(_msgSender(), spender, amount);
         return true;
     }
 
     function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
         _transfer(sender, recipient, amount);
         _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
         return true;
     }
 
     function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
         _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
         return true;
     }
 
     function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
         _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
         return true;
     }

     function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_tradingActive, "Could not transfer Token");

        if(_onPrivateSale) {
            privateSaleData[to]._isprivateSale = true;
            privateSaleData[to].amount = amount;
            privateSaleData[to].privateSaleTimeStamp = block.timestamp;
        }

        if(privaresaledata[from]._isprivateSale && block.timestamp - privatesaleData[from].privateSaleTimeStamp < _privateSaleTimeLimit) {
           require(balanceOf(from) >= privatesaledata[from].amount + amount, "privatesaleAddress only send reflection amount in 3 months");
        }

        if(from != owner() && to != owner()) {

            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            require(amount + balanceOf(to) <= _maxwalletamount, "transfer amount exceeds the maxWalletAmount.");

            uint256 amountETH = amount.mul(_getRateTokenAndETH());

            if (block.timestamp - transactionData[from].timestamp < _dailyTimeLimit) {
               require(transactionData[from].amount + amountETH <= _dailymaxTxAmount, "Transfer amount exceeds the dailymaxTxAmount.");
               transactionData[from].amount += amountETH;
            } else {
               transactionData[from].timestamp = block.timestamp;
               transactionData[from].amount = amountETH;
            }
        }
        
        

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }


 
     function isExcludedFromReward(address account) public view returns (bool) {
         return _isExcluded[account];
     }
 
     function totalFees() public view returns (uint256) {
         return _tFeeTotal;
     }
 
     function deliver(uint256 tAmount) public {
         address sender = _msgSender();
         require(!_isExcluded[sender], "Excluded addresses cannot call this function");
         (uint256 rAmount,,,,,) = _getValues(tAmount);
         _rOwned[sender] = _rOwned[sender].sub(rAmount);
         _rTotal = _rTotal.sub(rAmount);
         _tFeeTotal = _tFeeTotal.add(tAmount);
     }
 
     function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
         require(tAmount <= _tTotal, "Amount must be less than supply");
         if (!deductTransferFee) {
             (uint256 rAmount,,,,,) = _getValues(tAmount);
             return rAmount;
         } else {
             (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
             return rTransferAmount;
         }
     }
 
     function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
         require(rAmount <= _rTotal, "Amount must be less than total reflections");
         uint256 currentRate =  _getRate();
         return rAmount.div(currentRate);
     }
 
     function excludeFromReward(address account) public onlyOwner() {
         // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
         require(!_isExcluded[account], "Account is already excluded");
         if(_rOwned[account] > 0) {
             _tOwned[account] = tokenFromReflection(_rOwned[account]);
         }
         _isExcluded[account] = true;
         _excluded.push(account);
     }
 
     function includeInReward(address account) external onlyOwner() {
         require(_isExcluded[account], "Account is already excluded");
         for (uint256 i = 0; i < _excluded.length; i++) {
             if (_excluded[i] == account) {
                 _excluded[i] = _excluded[_excluded.length - 1];
                 _tOwned[account] = 0;
                 _isExcluded[account] = false;
                 _excluded.pop();
                 break;
             }
         }
     }
     
     function excludeFromFee(address account) public onlyOwner {
         _isExcludedFromFee[account] = true;
     }
     
     function includeInFee(address account) public onlyOwner {
         _isExcludedFromFee[account] = false;
     }
     
     function setBuyTaxPercent(uint256 reflectionBuyTax, uint256 liquidityBuyTax, uint256 marketingBuyTax) external onlyOwner() {
         _reflectionBuyTax = reflectionBuyTax;
         _liquidityBuyTax = liquidityBuyTax;
         _marketingBuyTax = marketingBuyTax;
     }
     
     function setSellTaxPercent(uint256 reflectionSellTax, uint256 liquiditySellTax, uint256 marketingSellTax) external onlyOwner() {
         _reflectionSellTax = reflectionSellTax;
         _liquiditySellTax = liquiditySellTax;
         _marketingSellTax = marketingSellTax;
     }
 
     function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
         swapAndLiquifyEnabled = _enabled;
         emit SwapAndLiquifyEnabledUpdated(_enabled);
     }
     
      //to recieve ETH from uniswapV2Router when swaping
     receive() external payable {}
 
     function _reflectTax(uint256 rReflection, uint256 tReflection) private {
         _rTotal = _rTotal.sub(rReflection);
         _tFeeTotal = _tFeeTotal.add(tReflection);
     }
 
     function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
         (uint256 tTransferAmount, uint256 tReflection, uint256 tLiquidity, tMarketing) = _getTValues(tAmount);
         (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection) = _getRValues(tAmount, tReflection, tLiquidity, tMarketing, _getRate());
         return (rAmount, rTransferAmount, rReflection, tTransferAmount, tReflection, tLiquidity, tMarketing);
     }
 
     function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
         uint256 tReflection = calculateReflectionTax(tAmount);
         uint256 tLiquidity = calculateLiquidityTax(tAmount);
         uint256 tMarketing = calculateMarketingTax(tAmount);
         uint256 tTransferAmount = tAmount.sub(tReflection).sub(tLiquidity).sub(tMarketing);
         return (tTransferAmount, tReflection, tLiquidity, tMarketing);
     }
 
     function _getRValues(uint256 tAmount, uint256 tReflection, uint256 tLiquidity, uint256 tMarketing, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
         uint256 rAmount = tAmount.mul(currentRate);
         uint256 rReflection = tReflection.mul(currentRate);
         uint256 rLiquidity = tLiquidity.mul(currentRate);
         uint256 rMarketing = tMarketing.mul(currentRate);
         uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rMarketing);
         return (rAmount, rTransferAmount, rRefletion);
     }
 
     function _getRate() private view returns(uint256) {
         (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
         return rSupply.div(tSupply);
     }
 
     function _getCurrentSupply() private view returns(uint256, uint256) {
         uint256 rSupply = _rTotal;
         uint256 tSupply = _tTotal;      
         for (uint256 i = 0; i < _excluded.length; i++) {
             if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
             rSupply = rSupply.sub(_rOwned[_excluded[i]]);
             tSupply = tSupply.sub(_tOwned[_excluded[i]]);
         }
         if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
         return (rSupply, tSupply);
     }
     
     function _takeLiquidity(uint256 tLiquidity) private {
         uint256 currentRate =  _getRate();
         uint256 rLiquidity = tLiquidity.mul(currentRate);
         _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
         if(_isExcluded[address(this)])
             _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
     }

     function _takeMarketing(uint256 tMarketing) private {
         uint256 currentRate = _getRate();
         uint256 rMarketing = tMarketing.mul(currentRate);
         _rOwned[_marketingAddress] = _rOwned[_marketingAddress].add(rMarketing);
         if(_isExcluded[_marketingAddress])
            _tOwned[_marketingAddress] = _tOwned[_marketingAddress].add(tMarketing);
     }
     
     function calculateReflectionTax(uint256 _amount) private view returns (uint256) {
         return _amount.mul(_reflectionTax).div(
             10**2
         );
     }
 
     function calculateLiquidityTax(uint256 _amount) private view returns (uint256) {
         return _amount.mul(_liquidityTax).div(
             10**2
         );
     }

     function calculateMarketingTax(uint256 _amount) private view returns (uint256) {
         return _amount.mul(_marketingTax).div(
             10**2
         );
     }
     
     function removeAllTax() private {                 
         _reflectionTax = 0;
         _liquidityTax = 0;
         _marketingTax = 0;
     }
     
     function setTaxBuyTax() private {
        _reflectionBuyTax = _reflectionTax;
        _liquidityBuyTax = _liquidityTax;
        _marketingBuyTax = _marketingTax;
     }

     function setTaxSellTax() private {
        _reflectionSellTax = _reflectionTax;
        _liquiditySellTax = _liquidityTax;
        _marketingSellTax = _marketingTax;
     }
     
     function isExcludedFromFee(address account) public view returns(bool) {
         return _isExcludedFromFee[account];
     }
 
     function _approve(address owner, address spender, uint256 amount) private {
         require(owner != address(0), "ERC20: approve from the zero address");
         require(spender != address(0), "ERC20: approve to the zero address");
 
         _allowances[owner][spender] = amount;
         emit Approval(owner, spender, amount);
     }
 

 
     function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
         // split the contract balance into halves
         uint256 half = contractTokenBalance.div(2);
         uint256 otherHalf = contractTokenBalance.sub(half);
 
         // capture the contract's current ETH balance.
         // this is so that we can capture exactly the amount of ETH that the
         // swap creates, and not make the liquidity event include any ETH that
         // has been manually sent to the contract
         uint256 initialBalance = address(this).balance;
 
         // swap tokens for ETH
         swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
 
         // how much ETH did we just swap into?
         uint256 newBalance = address(this).balance.sub(initialBalance);
 
         // add liquidity to uniswap
         addLiquidity(otherHalf, newBalance);
         
         emit SwapAndLiquify(half, newBalance, otherHalf);
     }
 
     function swapTokensForEth(uint256 tokenAmount) private {
         // generate the uniswap pair path of token -> weth
         address[] memory path = new address[](2);
         path[0] = address(this);
         path[1] = uniswapV2Router.WETH();
 
         _approve(address(this), address(uniswapV2Router), tokenAmount);
 
         // make the swap
         uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
             tokenAmount,
             0, // accept any amount of ETH
             path,
             address(this),
             block.timestamp
         );
     }
 
     function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
         // approve token transfer to cover all possible scenarios
         _approve(address(this), address(uniswapV2Router), tokenAmount);
 
         // add the liquidity
         uniswapV2Router.addLiquidityETH{value: ethAmount}(
             address(this),
             tokenAmount,
             0, // slippage is unavoidable
             0, // slippage is unavoidable
             owner(),
             block.timestamp
         );
     }
 
     //this method is responsible for taking all fee, if takeFee is true
     function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
         if(!takeFee) {
            removeAllTax();
         } else if (sender == uniswapV2Pair) {
             setTaxBuyTax();
         } else  {
             setTaxSellTax();
         } 
             
         
         if (_isExcluded[sender] && !_isExcluded[recipient]) {
             _transferFromExcluded(sender, recipient, amount);
         } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
             _transferToExcluded(sender, recipient, amount);
         } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
             _transferStandard(sender, recipient, amount);
         } else if (_isExcluded[sender] && _isExcluded[recipient]) {
             _transferBothExcluded(sender, recipient, amount);
         } else {
             _transferStandard(sender, recipient, amount);
         }
        
     }
 
     function _transferStandard(address sender, address recipient, uint256 tAmount) private {
         (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection, uint256 tTransferAmount, uint256 tReflection, uint256 tLiquidity, uint256 tMarketing) = _getValues(tAmount);
         _rOwned[sender] = _rOwned[sender].sub(rAmount);
         _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
         _takeLiquidity(tLiquidity);
         _takeMarketing(tMarketing);
         _reflectTax(rReflection, tReflection);
         emit Transfer(sender, recipient, tTransferAmount);
     }
 
     function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
         (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection, uint256 tTransferAmount, uint256 tReflection, uint256 tLiquidity, uint256 tMarketing) = _getValues(tAmount);
         _rOwned[sender] = _rOwned[sender].sub(rAmount);
         _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
         _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
         _takeLiquidity(tLiquidity);
         _takeMarketing(tMarketing);
         _reflectTax(rReflection, tReflection);
         emit Transfer(sender, recipient, tTransferAmount);
     }
 
     function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
         (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection, uint256 tTransferAmount, uint256 tReflection, uint256 tLiquidity, uint256 tMarketing) = _getValues(tAmount);
         _tOwned[sender] = _tOwned[sender].sub(tAmount);
         _rOwned[sender] = _rOwned[sender].sub(rAmount);
         _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
         _takeLiquidity(tLiquidity);
         _takeMarketing(tMarketing);
         _reflectTax(rReflection, tReflection);
         emit Transfer(sender, recipient, tTransferAmount);
     }

     function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
         (uint256 rAmount, uint256 rTransferAmount, uint256 rReflection, uint256 tTransferAmount, uint256 tReflection, uint256 tLiquidity, uint256 tMarketing) = _getValues(tAmount);
         _tOwned[sender] = _tOwned[sender].sub(tAmount);
         _rOwned[sender] = _rOwned[sender].sub(rAmount);
         _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
         _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
         _takeLiquidity(tLiquidity);
         _takeMarketing(tMarketing);
         _reflectTax(rReflection, tReflection);
         emit Transfer(sender, recipient, tTransferAmount);
     }

     function _getRateTokenAndETH() private view returns(uint256){
         uint256 amountToken = balanceOf(uniswapV2Pair);
         address WETH = uniswapV2Router.WETH();
         uint256 amountETH = WETH.BalanceOf(uniswapV2Pair);
         uint256 rateTokenAndETH;
         if(amountETH == 0) {
             rateTokenAndETH = 0;
         } else {
             rateTokenAndETH = amountToken.div(amountETH);
         }
         return rateTokenAndETH;
     }

     function includeblackList(address sender) public onlyOwner {
        _isBlacklist[sender] = true;        
     } 

     function exculdeBlackList(address account) public onlyOwner {
         _isBlacklist[account] = false;
     }

     function setPresaleList(address account, uint256 amount) internal {

     }

     function burn(uint256 tBurn) external {
 
         address sender = _msgSender();
         require(sender != address(0), "ERC20: burn from the zero address");
         require(sender != address(deadAddress), "ERC20: burn from the burn address");
 
         uint256 balance = balanceOf(sender);
         require(balance >= tBurn, "ERC20: burn amount exceeds balance");
 
         uint256 rBurn = tBurn.mul(_getRate());
 
         // remove the amount from the sender's balance first
         _rOwned[sender] = _rOwned[sender].sub(rBurn);
         
         if (_isExcluded[sender])
             _tOwned[sender] = _tOwned[sender].sub(tBurn);
 
         _burnTokens( sender, tBurn, rBurn );
     }

     function setEnableTrading(bool tradingActive) external onlyOwner {
        _tradingActive = tradingActive;

    } 
 
     /**
      * @dev "Soft" burns the specified amount of tokens by sending them
      * to the burn address
      */
     function _burnTokens(address sender, uint256 tBurn, uint256 rBurn) internal {
 
         /**
          * @dev Do not reduce _totalSupply and/or _reflectedSupply. (soft) burning by sending
          * tokens to the burn address (which should be excluded from rewards) is sufficient
          * in FleetRewards
          */
         _rOwned[deadAddress] = _rOwned[deadAddress].add(rBurn);
         if (_isExcluded[deadAddress])
             _tBurn[deadAddress] = _tBurn[deadAddress].add(tBurn);
 
         /**
          * @dev Emit the event so that the burn address balance is updated (on bscscan)
          */
         emit Transfer(sender, deadAddress, tBurn);
     }
 
 }