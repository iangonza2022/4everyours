
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";


interface IERC2981Royalties { 
    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);
}

/// @dev This is a contract used to add ERC2981 support to ERC721 and 1155
abstract contract ERC2981Base is ERC165, IERC2981Royalties {
    struct RoyaltyInfo {
        address recipient;
        uint24 amount;
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}

contract NFTContract is ERC1155, Ownable, ERC2981Base {
    
    uint256 public constant ARTWORK = 0; 
    RoyaltyInfo private _royalties;
    
    constructor() ERC1155("https://mutantusagi.online/ipfs/{id}.json") {
        _setRoyalties(0xc133dC8987435A6191cF1e6045BFe97fF90230E4 , 700);
        for(uint i = 0; i < 10; i++) {
            _mint(msg.sender, ARTWORK, i, ""); 
        }
    }
    
    function contractURI() public pure returns (string memory) {
        return "https://mutantusagi.online/contractmetadata/";
    }
    
    function mint( address to, uint256 id, uint256 amount) public onlyOwner {
        _mint(to, id, amount, "");
    }
    function burn( address from, uint256 id, uint256 amount) public {
        require(msg.sender == from);
        _burn(from, id, amount);
    } 

    
    // Value is in basis points so 10000 = 100% , 100 = 1% etc
    function _setRoyalties(address recipient, uint256 value) internal {
        require(value <= 10000, 'ERC2981Royalties: Too high');
        _royalties = RoyaltyInfo(recipient, uint24(value));
    }


    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory royalties = _royalties;
        receiver = royalties.recipient;
        royaltyAmount = (value * royalties.amount) / 10000;
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981Base) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
}