pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    function totalShares() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract Faucet {

    address public owner;
    
    constructor(address initialXCHFContractAddress) public {
        owner = msg.sender;
        XCHF = ERC20(initialXCHFContractAddress);
    }

    using SafeMath for uint256;

    uint256 public retrievalAmount;
    uint256 public retrievalLimit;

    address public XCHFAddress;

    ERC20 public XCHF;

    mapping (address => uint256) public amountRetrieved;

    function getSomeXCHF() public {
        address retriever = msg.sender;
        amountRetrieved[retriever].add(retrievalAmount);
        require(amountRetrieved[retriever] <= retrievalLimit, "You have reached the retrieval limit");
        require(XCHF.balanceOf(address(this)) >= retrievalAmount, "Reserves insufficient");
        require(XCHF.transfer(retriever, retrievalAmount), "XCHF transfer failed");
    }

}

