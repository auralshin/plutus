//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@routerprotocol/router-crosstalk/contracts/RouterCrossTalk.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface PlutusNFTContract {
    function mint(address _user, string memory _pValue, uint256 _blockNumber) external;
    function updateNFT(address _user, string memory _pValue, uint256 _blockNumber) external;
}


contract PlutusCrossChainNFT is RouterCrossTalk {
    address public _pltNFTContract;
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

    function updatePltNftContract(address thecontractAddress) public {
        _pltNFTContract = thecontractAddress;
    }

    function callMintNFTCrossChain(
        uint8 _chainID,
        address _userAddress, 
        string memory _pValue, 
        uint256 _blockNumber,
        uint256 _crossChainGasLimit,
        uint256 _crossChainGasPrice
    ) external onlyOwner returns (bool) {
        nonce = nonce + 1;
        bytes memory data = abi.encode(_userAddress, _pValue, _blockNumber);
        bytes4 _selector = bytes4(keccak256("callMintNFT(address,string,uint)"));
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

    function callUpdateNFTCrossChain(
        uint8 _chainID,
        address _userAddress, 
        string memory _pValue,
        uint256 _blockNumber,
        uint256 _crossChainGasLimit,
        uint256 _crossChainGasPrice
    ) external onlyOwner returns (bool) {
        nonce = nonce + 1;
        bytes memory data = abi.encode(_userAddress, _pValue, _blockNumber);
        bytes4 _selector = bytes4(keccak256("callUpdateNFT(address,string,uint)"));
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

    function callMintNFT(
        address _userAddress, 
        string memory _pValue, 
        uint256 _blockNumber
    ) external isSelf {
        PlutusNFTContract nftContract = PlutusNFTContract(_pltNFTContract);
        nftContract.mint(_userAddress, _pValue, _blockNumber);
    }


    function callUpdateNFT(
        address _userAddress, 
        string memory _pValue, 
        uint256 _blockNumber
    ) external isSelf {
        PlutusNFTContract nftContract = PlutusNFTContract(_pltNFTContract);
        nftContract.updateNFT(_userAddress, _pValue, _blockNumber);
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

    function _routerSyncHandler(bytes4 _selector, bytes memory _data)
        internal
        override
        returns (bool, bytes memory)
    {
        (address _userAddress, string memory _pValue, uint256 _blockNumber ) = abi.decode(_data, (address, string, uint256));

        if( bytes4(keccak256("callMintNFT(address,string,uint)")) == _selector ) {
            (bool success, bytes memory returnData) = 
            address(this).call( abi.encodeWithSelector(_selector, _userAddress, _pValue, _blockNumber) );
            return (success, returnData);
        } else if ( bytes4(keccak256("callUpdateNFT(address,string,uint)")) == _selector ) {
            (bool success, bytes memory returnData) = 
            address(this).call( abi.encodeWithSelector(_selector, _userAddress, _pValue, _blockNumber) );
            return (success, returnData);
        }
    }

    function recoverFeeTokens() external onlyOwner {
        address feeToken = this.fetchFeeToken();
        uint256 amount = IERC20(feeToken).balanceOf(address(this));
        IERC20(feeToken).transfer(owner, amount);
    }

    function parseAddress(string memory _a)
        internal
        pure
        returns (address _parsedAddress)
    {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint256 i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
}