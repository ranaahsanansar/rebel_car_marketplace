// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC6551Registry {

    event AccountCreated(
        address account,
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    );

    function createAccount(
        // address implementation,
        // uint256 chainId,
        // address tokenContract,
        uint256 tokenId
        // uint256 seed,
        // bytes calldata initData
    ) external returns (address);

    function account(
       
        uint256 tokenId
    ) external view returns (address);


    function getAccount(uint256 _tokenId) external view returns (address);

    function getTokenId(address _accountAddress) external view returns (uint256);
}