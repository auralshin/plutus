//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@routerprotocol/router-crosstalk/contracts/RouterCrossTalk.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface SwapV2Router02 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

contract PlutusCrossChainLP is RouterCrossTalk {
    address public _lpRouter;
    address public owner;
    uint256 public nonce;
    mapping(uint256 => bytes32) public nonceToHash;

    constructor(address _handler) RouterCrossTalk(_handler) {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function _approveFees(address _feeToken, uint256 _value) public {
        approveFees(_feeToken, _value);
    }

    function setLinker(address _linker) external onlyOwner {
        setLink(_linker);
    }

    function setFeesToken(address _feeToken) external onlyOwner {
        setFeeToken(_feeToken);
    }

    function updateLPRouter(address theRouterAddress) public {
        _lpRouter = theRouterAddress;
    }

    function encodeAddLiquidityData( 
        address _tokenA,
        address _tokenB,
        uint _amountADesired,
        uint _amountBDesired,
        uint _amountAMin,
        uint _amountBMin,
        address _to,
        uint _deadline
    ) public pure returns (bytes memory) {
        return (abi.encode(_tokenA, _tokenB, _amountADesired, _amountBDesired, _amountAMin, _amountBMin, _to, _deadline )); 
    }

    function addLiquidityCrossChain(
        uint8 _chainID,
        bytes memory data,
        uint256 _crossChainGasLimit,
        uint256 _crossChainGasPrice
    ) external onlyOwner returns (bool) {
        bytes4 _selector = bytes4(keccak256("addLiquidityForUser(address, address, uint, uint, uint, uint, address, uint)"));
        //Standard
        nonce = nonce + 1;
        (bool success, bytes32 hash) = routerSend(
            _chainID,
            _selector,
            data,
            _crossChainGasLimit,
            _crossChainGasPrice
        );
        nonceToHash[nonce] = hash;
        require(success == true, "unsuccessful");
        return success;
    }

    function _routerSyncHandler(bytes4 _selector, bytes memory _data)
        internal
        override
        returns (bool, bytes memory)
    {
        (address _tokenA,
        address _tokenB,
        uint _amountADesired,
        uint _amountBDesired,
        uint _amountAMin,
        uint _amountBMin,
        address _to,
        uint _deadline) =  abi.decode(_data, (address, address, uint, uint, uint, uint, address, uint));
        (bool success, bytes memory data) = address(this).call(
            abi.encodeWithSelector(_selector, _tokenA, _tokenB, _amountADesired, _amountBDesired, _amountAMin, _amountBMin, _to, _deadline)
        );
        return (success, data);
    }

    function callAddLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountADesired,
        uint _amountBDesired,
        uint _amountAMin,
        uint _amountBMin,
        address _to,
        uint _deadline
    ) external isSelf {
        SwapV2Router02 theContract = SwapV2Router02(_lpRouter);
        theContract.addLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired, _amountAMin, _amountBMin, _to, _deadline);
    }

    function replaySetValueCrossChain(
        uint256 _nonce,
        uint256 _crossChainGasLimit,
        uint256 _crossChainGasPrice
    ) external onlyOwner {
        routerReplay(
            nonceToHash[_nonce],
            _crossChainGasLimit,
            _crossChainGasPrice
        );
    }

    function recoverFeeTokens() external onlyOwner {
        address feeToken = this.fetchFeeToken();
        uint256 amount = IERC20(feeToken).balanceOf(address(this));
        IERC20(feeToken).transfer(owner, amount);
    }
}