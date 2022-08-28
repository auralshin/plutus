// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract PlutusNFTContract is ERC721 {
    using Strings for uint256;

    uint256 public tokenCounter;

    struct PortfolioValue {
        uint256 _tokenId;
        address _user;
        string _portfolioValue;
        uint256 _blockNumber;
    }

    mapping(uint256 => PortfolioValue) private _tokenURIs;
    mapping(address => uint256) private _addressTokenId;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
    }

    function mint(address _user, string memory _pValue, uint256 _blockNumber) public {
        uint256 tokenId = _addressTokenId[_user];
        require(!_exists(tokenId), "Token already exists.");

        _addressTokenId[_user] = ++tokenCounter;
        _mint(_user, tokenCounter);
        _setPortfolioValue(
            tokenCounter,
            PortfolioValue(tokenCounter, _user, _pValue, _blockNumber)
        );

    }

    function _setPortfolioValue(uint256 tokenId, PortfolioValue memory uPValue)
        internal
        virtual
    {
        require(_exists(tokenId), "URI set of nonexistent token");
        _tokenURIs[tokenId] = uPValue;
    }

    function updateNFT(address _user, string memory _pValue, uint256 _blockNumber) public {
        uint256 _tokenId = _addressTokenId[_user];
        require(_exists(_tokenId), "Token doesn't exist.");
        _tokenURIs[_tokenId]._portfolioValue = _pValue;
        _tokenURIs[_tokenId]._blockNumber = _blockNumber;
    }

    function isNFTMinted(address _user) public view returns (uint256) {
        return _addressTokenId[_user];
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "URI query for nonexistent token");
        string memory name = string(
            abi.encodePacked(
                " Token ID #",
                toString(_tokenURIs[tokenId]._tokenId)
            )
        );
        string memory description = "User Portfolio Value";
        string memory image = generateBase64Image(tokenId);
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function generateBase64Image(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        return Base64.encode(bytes(generateImage(tokenId)));
    }

    function generateImage(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 156.32 156.32">',
                    "<defs>",
                    "<style>.cls-1{fill:#08144d;}.cls-2,.cls-4,.cls-6,.cls-7{fill:#4fb828;}.cls-3,.cls-5,.cls-8{fill:#fff;}.cls-4,.cls-8{font-size:15px;font-family:Montserrat-ExtraBold, Montserrat ExtraBold;font-weight:800;}.cls-5,.cls-7{font-size:6px;}.cls-5,.cls-6,.cls-7{font-family:Montserrat-Bold, Montserrat;font-weight:700;}.cls-6{font-size:5.3px;}</style>",
                    '<clipPath id="clip-path">',
                    '<rect class="cls-1" width="156.32" height="156.32"/>',
                    "</clipPath>",
                    "</defs>",
                    "<title>Plutus_NFT</title>",
                    '<rect class="cls-1" width="156.32" height="156.32"/>',
                    '<polygon class="cls-2" points="120.18 138.52 105.74 128.74 105.74 148.3 120.18 138.52"/>',
                    '<polygon class="cls-2" points="134.55 138.52 120.11 128.74 120.11 148.3 134.55 138.52"/>',
                    '<polygon class="cls-2" points="148.92 138.52 134.47 128.74 134.47 148.3 148.92 138.52"/>',
                    '<polygon class="cls-3" points="37.29 19.41 51.73 29.19 51.73 9.63 37.29 19.41"/>',
                    '<polygon class="cls-3" points="22.92 19.41 37.37 29.19 37.37 9.63 22.92 19.41"/>',
                    '<polygon class="cls-3" points="8.55 19.41 23 29.19 23 9.63 8.55 19.41"/>',
                    '<text class="cls-4" transform="translate(30.95 84.86)">Portfolio Value</text>',
                    '<text class="cls-5" transform="translate(111.11 21.29)">Token#',
                    toString(tokenId),
                    "</text>",
                    '<text class="cls-6" transform="translate(10.54 57.8)">0x',
                    toAsciiString(_tokenURIs[tokenId]._user),
                    "</text>",
                    '<text class="cls-7" transform="translate(15.78 140.52)">Block#',
                    toString(_tokenURIs[tokenId]._blockNumber),
                    "</text>",
                    '<text class="cls-8" transform="translate(65.43 104.52)">',
                    _tokenURIs[tokenId]._portfolioValue,
                    "</text>",
                    "</svg>"
                )
            );
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function stringToBytes32(string memory source)
        public
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
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
            }/*  */
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
}