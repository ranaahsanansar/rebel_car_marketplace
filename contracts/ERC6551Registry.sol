// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/openzeppelin/contracts/utils/Create2.sol";
import "contracts/interfaces/IERC6551Registry.sol";
import "contracts/openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ERC6551Registry is IERC6551Registry {
    error InitializationFailed();

    address tokenContract;
    address implementationAddress;
    uint256 chainId;
    bytes initData;
    uint256 salt;
    address deployer;

    constructor(address _tokenContract, address _implementationAddress, uint256 _salt){
        tokenContract = _tokenContract;
        implementationAddress = _implementationAddress;
        chainId = block.chainid;
        salt = _salt;
        deployer = msg.sender;
    }

    mapping(address => uint256) public accountToTokenId;
    mapping(uint256 => address) public tokenIdToAccount;


    // TODO: Set Security Check 
    function setInitData(bytes memory data) external {
        require(deployer == msg.sender, "Only Deployer can use this function");
        initData = data;
    }

    function getAccount(uint256 _tokenId) external view returns (address) {
        return tokenIdToAccount[_tokenId];
    }

    function getTokenId(address _accountAddress) external view returns (uint256) {
        return accountToTokenId[_accountAddress];
    }

    function createAccount(
        uint256 tokenId
    ) external returns (address) {
        IERC721 contractInstance = IERC721(tokenContract);
        require(contractInstance.ownerOf(tokenId) != address(0), "Invalid Token ID");
        require(tokenIdToAccount[tokenId] == address(0), "Account already deployed");
        bytes memory code = _creationCode(implementationAddress, chainId, tokenContract, tokenId, salt);

        address _account = Create2.computeAddress(
            bytes32(salt),
            keccak256(code)
        );

        if (_account.code.length != 0) return _account;

        _account = Create2.deploy(0, bytes32(salt), code);

        if (initData.length != 0) {
            (bool success, ) = _account.call(initData);
            if (!success) revert InitializationFailed();
        }

        accountToTokenId[_account] = tokenId;
        tokenIdToAccount[tokenId] = _account;

        emit AccountCreated(
            _account,
            implementationAddress,
            chainId,
            tokenContract,
            tokenId,
            salt
        );

        return _account;
    }

    function account(
        uint256 tokenId
    ) external view returns (address) {
        bytes32 bytecodeHash = keccak256(
            _creationCode(implementationAddress, chainId, tokenContract, tokenId, salt)
        );

        return Create2.computeAddress(bytes32(salt), bytecodeHash);
    }

    function _creationCode(
        address implementation_,
        uint256 chainId_,
        address tokenContract_,
        uint256 tokenId_,
        uint256 salt_
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                hex"3d60ad80600a3d3981f3363d3d373d3d3d363d73",
                implementation_,
                hex"5af43d82803e903d91602b57fd5bf3",
                abi.encode(salt_, chainId_, tokenContract_, tokenId_)
            );
    }
}