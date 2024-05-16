
import { accountAbi } from "./abi.js";
import { ethers } from "ethers";
import abiDecoder from "abi-decoder";

const provider = new ethers.providers.JsonRpcProvider('https://rpc.atlantischain.network')

const contract = new ethers.Contract("0x0e16Ba8fAcc625D76147331003e79D107b0feEbA", accountAbi, provider);
abiDecoder.addABI(accountAbi);

contract.on('TransactionExecuted', (contractAddress, value , data)=>{
    console.log(contractAddress, value, data)
    // "Store the data in DB
    const decodedResult = abiDecoder.decodeMethod(data);
    console.log(`*********${decodedResult.name}**********`)
    decodedResult.params.forEach(item => {
        console.log(item.name);
        console.log(item.value);
    });
    console.log("*******************")

})
