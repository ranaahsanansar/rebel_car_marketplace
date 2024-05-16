// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "contracts/openzeppelin/contracts/token/ERC721/IERC721.sol";
import "contracts/openzeppelin/contracts/token/ERC20/IERC20.sol";
import "contracts/openzeppelin/contracts/token/ERC20/IERC20.sol";
import "contracts/openzeppelin/contracts/interfaces/IERC1271.sol";
import "contracts/openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "contracts/openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "contracts/openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./interfaces/IERC6551Account.sol";
import "./lib/ERC6551AccountLib.sol";
import "contracts/openzeppelin/contracts/access/Ownable.sol";


contract ERC6551Account is IERC165, IERC1271, IERC6551Account {

    bool public isInitialized = false;
    uint256 public nonce;
    address public mechanicContract ;


    // modifiers 
    modifier onlyMechanicContract(){
        require(msg.sender == mechanicContract, "Only mechanic can call this function");
        _;
    }


    // TODO: Change This 
    receive() external payable {}


    // One time function 
   function init(address _mechanicContract) public {
    require(isInitialized == false , "Contract is already initialzed");
    mechanicContract = _mechanicContract;
    isInitialized = true;
   }


    // TODO: add a modifier to this function who can update the mechanic address
    function updateMechanicAddress(address _mechanicContract) public {
    mechanicContract = _mechanicContract;
   }

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable onlyMechanicContract returns (bytes memory result)  {
        
        ++nonce;

        emit TransactionExecuted(to, value, data);

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function token()
        external
        view
        returns (
            uint256,
            address,
            uint256
        )
    {
        return ERC6551AccountLib.token();
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = this.token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return (interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC6551Account).interfaceId);
    }

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        returns (bytes4 magicValue)
    {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }

    function safeTransferFrom721(address from, address to, uint256 tokenId, address contractAddress) onlyMechanicContract public {
        ++nonce;
        bytes memory data = abi.encodeWithSignature("safeTransferFrom721(address,address,uint256,address)", from,  to,  tokenId, contractAddress);
        emit TransactionExecuted(contractAddress, 0, data);
        return IERC721(contractAddress).safeTransferFrom(from, to, tokenId);
    }

    function transferFrom721(address from, address to, uint256 tokenId, address contractAddress) onlyMechanicContract public {
        ++nonce;
        bytes memory data = abi.encodeWithSignature("transferFrom721(address,address,uint256,address)", from,  to,  tokenId, contractAddress);
        emit TransactionExecuted(contractAddress, 0, data);
        return IERC721(contractAddress).transferFrom(from, to, tokenId);
    }


    function transferFrom20(address from, address to, uint256 amount, address contractAddress) onlyMechanicContract public returns (bool){
        ++nonce;
        bytes memory data = abi.encodeWithSignature("transferFrom20(address,address,uint256,address)", from,  to,  amount, contractAddress);
        emit TransactionExecuted(contractAddress, 0, data);
        return IERC20(contractAddress).transferFrom(from, to, amount);
    }

    function transfer20(address to, uint256 amount, address contractAddress) onlyMechanicContract public returns (bool){
        ++nonce;
        bytes memory data = abi.encodeWithSignature("transfer20(address,uint256,address)", amount,  to,  amount, contractAddress);
        emit TransactionExecuted(contractAddress, 0, data);
        return IERC20(contractAddress).transfer(to, amount);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public view returns (bytes4) {
        (uint256 numberOfAccounts ,address tokenAddress ,uint256 tokenIdOfThisAccount ) = this.token();
        if(tokenId ==  tokenIdOfThisAccount && tokenAddress == msg.sender){
            revert("Token can't transfer to it's own address");
        }
        // Indicating the contract doesn't handle ERC721 tokens
        if(operator != mechanicContract){
        revert("This contract will accept ERC721 from official system contract");
        }else {
            // Must return the ERC721_RECEIVED selector to confirm successful reception
            return this.onERC721Received.selector;
        }
    }

}