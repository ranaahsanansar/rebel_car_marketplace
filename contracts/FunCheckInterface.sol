
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface FunChecks {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom721(address from, address to, uint256 tokenId, address contractAddress) external ;
    function transferFrom721(address from, address to, uint256 tokenId, address contractAddress)  external;
    // TODO: Add Approve for All and Approve and Bulk Transfer 
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function bulkTransfer(address from, address[] memory to, uint256[] memory tokenIds) external;
}