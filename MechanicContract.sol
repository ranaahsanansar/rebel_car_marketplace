// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/openzeppelin/contracts/token/ERC721/ERC721.sol";
import "contracts/interfaces/IERC6551Registry.sol";
import "contracts/interfaces/IERC6551Account.sol";

contract MechanicContract {

    IERC721 public  rcCollection ;
    IERC6551Registry public registeryContract;
    address public systemWallet;

    constructor(address _token_Collection, address _registeryContract, address _systenWallet){
        rcCollection = IERC721(_token_Collection);
        registeryContract = IERC6551Registry(_registeryContract);
        systemWallet = _systenWallet;
    }

    event DetachedSparePart(uint256 indexed sparePart, uint256 indexed  nftToken,  address previousTbaOwner, address superOwner);
    event AttachedSparePart(uint256 indexed sparePart, uint256 indexed  nftToken,  address previousOwner,  address indexed nftTba);


    modifier onlySystemWallet(){
        require(msg.sender == systemWallet, "Only System Wallet");
        _;
    }

    // TODO: Add Security logic to this function 
    function updateSystemWallet(address _newAddress) public onlySystemWallet {
        systemWallet = _newAddress;
    }

    // deatch part from RC_car and transfer to the owner of the car 
    function detachSparePart(uint256 _sparePartId)  external onlySystemWallet {
        
        address tbaAddress = rcCollection.ownerOf(_sparePartId);
        IERC6551Account tbaContract =  IERC6551Account(tbaAddress);
        address tokenOwner = tbaContract.owner();

        tbaContract.safeTransferFrom721(tbaAddress, tokenOwner, _sparePartId, address(rcCollection));

        emit DetachedSparePart(_sparePartId, registeryContract.getTokenId(tbaAddress), tbaAddress, tokenOwner);
       
    }


    // Attach part from onwer to rc_car
    function attachSparePart(uint256 _sparePartId , uint256 _token) external onlySystemWallet {
        require(_sparePartId != _token , "Token Id should be different" );
        address currentOwner = rcCollection.ownerOf(_sparePartId);

        address tbaAddress = registeryContract.getAccount(_token);

        rcCollection.safeTransferFrom(currentOwner, tbaAddress, _sparePartId);

        emit AttachedSparePart(_sparePartId, _token, currentOwner, tbaAddress);
    }

}