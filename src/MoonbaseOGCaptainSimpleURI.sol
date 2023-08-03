/**
 *Submitted for verification at FtmScan.com on 2023-01-14
*/

// SPDX-License-Identifier: MIT
// svg helper functions
pragma solidity ^0.8.0;
interface ISvg {
    function textClose() external pure returns (string memory);
    function textOpen(
        uint256 x, uint256 y, 
        string memory cssClass) external pure returns (string memory);
    function textOpenClose(
        uint256 x, uint256 y, 
        string memory cssClass) external pure returns (string memory);
    function begin() external pure returns (string memory);
     function style() external pure returns (string memory);   
     function bgRect(string memory color) external pure returns (string memory);

    function line(
        uint256 x1, uint256 y1, 
        uint256 x2, uint256 y2) external pure returns (string memory);
        function statPolygon(uint256[6] memory _stats, uint256 minX, uint256 minY,
     uint256 maxX, uint256 maxY) external pure returns (string memory);
}
interface ICaptain {
    function val(uint256 tokenId, string memory property) external view returns (uint256);
    function getStats(uint256 tokenId) external view returns (uint256, uint256, uint256);
    function getName(uint256 tokenId) external view returns (string memory);
}
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



contract MoonbaseCaptainURI is Ownable {
    string public TITLE = "Moonbase Captain";
    ISvg public svg;
    ICaptain captain;

    constructor(address _svg, address _captain) Ownable() {
        svg = ISvg(_svg);
        captain = ICaptain(_captain);
    }

    function changeSvgLib(address _svg) public onlyOwner {
        svg = ISvg(_svg);
    }
    function changeCaptainContract(address _captain) public onlyOwner {
        captain = ICaptain(_captain);
    }

    function blurb() internal pure returns (string memory) {
        return '"A Moonbase Captain. Captains are free to mint and are your character in the Moonbase Metaverse."';
    }
    function jsonify(uint256 tokenId, string memory stuff) internal view returns (string memory) {
        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "',TITLE,' #', 
            toString(tokenId), 
            '", "description": ',
            blurb(),
            ', "image": "data:image/svg+xml;base64,', 
            Base64.encode(bytes(stuff)), 
            '"}'))));
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    function rule_base() public pure returns (string memory) {
        return ' .base { fill: #afafaf; font-family: sans-serif; font-size: 14px;}';
    }

    function rule_big() public pure returns (string memory) {
        return ' .big { font-size: 20px; fill: white;}';
    }

    function rule_small() public pure returns (string memory) {
        return ' .small { font-size: 12px; fill: #c1c1c1;} .label {font-size: 8px; fill: #626262}';
    }


    string public extraCss = '';

    function changeExtraCss(string memory css) public onlyOwner {
        extraCss = css;
    }

    function style() public view returns (string memory) {
        return string(abi.encodePacked(
            '<style>',rule_base(),rule_big(),rule_small(),extraCss,'</style>'));
    }

    string[7] tiers = [
        "Average",
        "Good",
        "Very Good",
        "Great",
        "Fantastic",
        "Perfect",
        "Godlike"
    ];

    function _propsvg(uint256 tokenId, uint256 y, string memory property) internal view returns (string memory) {
        return string(abi.encodePacked(
            svg.textOpen(32,y,"base"),
            property,
            ": ",
            tiers[captain.val(tokenId, property)],
            svg.textClose()));
    }

    


    // get the tokenURI
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        (uint256 dex, uint256 wis, uint256 chr) = captain.getStats(tokenId);

        string[8] memory parts;
        uint256 gutter = 16;
        parts[0] = string(abi.encodePacked(
            svg.begin(),style(),svg.bgRect("000000")));
        parts[1] = string(abi.encodePacked(
            svg.textOpen(gutter*2,40,"base big"), 
            captain.getName(tokenId),
            svg.textClose()));
        parts[2] = string(abi.encodePacked(
            svg.textOpen(gutter*2,56,"base"),
            "Dexterity: ",
            toString(dex),
            svg.textClose()));
        parts[3] = string(abi.encodePacked(
            svg.textOpen(gutter*2,72,"base"),
            "Wisdom: ",
            toString(wis),
            svg.textClose()));
        parts[4] = string(abi.encodePacked(
            svg.textOpen(gutter*2,88,"base"),
            "Charisma: ",
            toString(chr),
            svg.textClose()));

        parts[5] = string(abi.encodePacked(
            svg.textOpen(gutter*2,108,"base small"),
            "Random Properties",
            svg.textClose(),
            svg.line(gutter*2,110,240,110)
            ));

        parts[6] = string(abi.encodePacked(
            _propsvg(tokenId, 124, "Leadership"),
            _propsvg(tokenId, 140, "Empathy"),
            _propsvg(tokenId, 156, "Creativity"),
            _propsvg(tokenId, 172, "Ambition"),
            _propsvg(tokenId, 188, "Patience"),
            _propsvg(tokenId, 204, "Friendliness"),
            _propsvg(tokenId, 220, "Happiness")
            ));
        parts[7] = string(abi.encodePacked(
            _propsvg(tokenId, 236, "Natural Speed"),
            _propsvg(tokenId, 252, "Natural Strength"),
            _propsvg(tokenId, 268, "Body Attractiveness"),
            _propsvg(tokenId, 284, "Face Attractiveness")
            ));

        
        
        string memory preOutput = string(abi.encodePacked(
            parts[0], 
            parts[1], 
            parts[2], 
            parts[3], 
            parts[4]));
        
        
        string memory output = string(abi.encodePacked(
            preOutput,
            parts[5], parts[6], parts[7],
            '<text x="248" y="330" class="base small">Moonbase Captain</text>',
            '<line x1="16" y1="16" x2="16" y2="334" stroke="white"/>',
            '</svg>'));

        return jsonify(tokenId, output);
    }

    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
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
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}