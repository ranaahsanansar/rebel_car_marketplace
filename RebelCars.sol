// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;


// Openzeppelin Version releas v5.0.2
import "contracts/openzeppelin/contracts/token/ERC721/ERC721.sol";
import "contracts/openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "contracts/openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    address public systemWallet ;

    constructor(address initialOwner, address _systemWallet)
        ERC721("RebelCars", "RC")
        Ownable(initialOwner)  
    {
        systemWallet = _systemWallet;
    }

    modifier onlySystemWallet(){
        require(msg.sender == systemWallet , "Only system wallet");
        _;
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    // According to our buisness logic we need to update the URI of Token
    function updateTokenUri(string memory _newUri , uint256 tokenId) public onlySystemWallet {
        _setTokenURI(tokenId, _newUri);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
