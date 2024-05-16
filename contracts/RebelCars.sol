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
        ERC721("Rebel Car NFTS", "RCN")
        Ownable(initialOwner)  
    {
        systemWallet = _systemWallet;
        _nextTokenId = 1;
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


    function bulkMint(address to, string[] memory uris) public onlyOwner  {
        require(uris.length > 0, "Empty URI array");
        for (uint256 i = 0; i < uris.length; i++) {
            uint256 tokenId = _nextTokenId;
            _nextTokenId++;
            _safeMint(to, tokenId);
            _setTokenURI(tokenId, uris[i]);
        }
    }


    function bulkTransfer(address from, address[] memory to, uint256[] memory tokenIds) external {
    require(from != address(0), "Invalid sender address");
    require(to.length == tokenIds.length, "Length of to addresses and tokenIds should be same");
    for (uint256 i = 0; i < tokenIds.length; i++) {
        require(to[i] != address(0), "Invalid recipient address");
        safeTransferFrom(from, to[i], tokenIds[i]);
    }
    }

    // TODO : add security check for this function
    function updateSystemWallet(address _newWallet) external onlySystemWallet {
        systemWallet = _newWallet;
    }
}
