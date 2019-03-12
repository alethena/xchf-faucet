pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";


interface ERC20 {
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    function totalShares() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract Faucet is Pausable, Ownable {
    
    constructor(address initialXCHFContractAddress) public {
        XCHFContractAddress = initialXCHFContractAddress;
        XCHF = ERC20(XCHFContractAddress);
    }

    using SafeMath for uint256;

    uint256 public retrievalAmount = 250*10**18;
    uint256 public retrievalLimit = 1000*10**18;

    address public XCHFContractAddress;

    ERC20 public XCHF;

    mapping (address => uint256) public amountRetrieved;

    function getSomeXCHF() public returns(bool){
        address retriever = msg.sender;
        amountRetrieved[retriever] = amountRetrieved[retriever].add(retrievalAmount);
        require(amountRetrieved[retriever] <= retrievalLimit, "You have reached the retrieval limit");
        require(XCHF.balanceOf(address(this)) >= retrievalAmount, "Reserves insufficient");
        require(XCHF.transfer(retriever, retrievalAmount), "XCHF transfer failed");
        return true;
    }

    function changeRetrievalAmounts(uint256 newRetrievalAmount, uint256 newNumberOfTimes) public onlyOwner() returns(bool) {
        require(newRetrievalAmount > 0, "Retrieval amount must be positive");
        require(newNumberOfTimes > 0, "Number of times must be positive");
        retrievalAmount = newRetrievalAmount;
        retrievalLimit = retrievalAmount.mul(newNumberOfTimes);
        return true;
    }

    function recoverXCHF(address to, uint256 amount) public onlyOwner() returns(bool) {
        require(XCHF.transfer(to, amount), "Transfer failed");
        return true;
    }

    function setXCHFAddress(address newXCHFContractAddress) public onlyOwner() {
        require(newXCHFContractAddress != address(0), "XCHF does not reside at 0x");
        XCHFContractAddress = newXCHFContractAddress;
        XCHF = ERC20(XCHFContractAddress);
    }

    function closeFaucet(address payable payoutAddress) public onlyOwner() {
        uint256 XCHFBalance = XCHF.balanceOf(address(this));
        require(recoverXCHF(payoutAddress, XCHFBalance), "Could not self destruct, funds not retrievable");
        selfdestruct(payoutAddress); 
    }
}

