pragma solidity ^0.4.11;
// <STATUSRSK_TEMPORAL_WALLET>
/*
Copyright (c) 2016-2017 Status RSK CO

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:


The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

contract owned {
    
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract Safe {

   // From rec: stack overflow link 
  function safeMul(uint256 a, uint256 b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }

}

contract TimeLock is owned, Safe {
    // custom data structure to hold locked funds and time

    bool public holdTransactions = false;

    struct accountData {
        uint256 balance = 0;
        uint256 proxyExpirationTime;
        address proxy;
    }

    // only one locked account per address
    mapping (address => accountData) accounts;

    mapping (address => bool) processing;

    function proxyDeposit(address proxy, uint256 authorizedSeconds, uint256 gasRate) payable {

        uint256 preload = safeMul(tx.gasprice, gasRate);
        uint256 amount = safeSub(msg.value, preload);

        if(holdTransactions) {
            if(msg.sender != owner) throw;
        }

        accounts[msg.sender].balance = safeAdd(accounts[msg.sender].balance, amount);
        accounts[msg.sender].proxy = proxy;
        accounts[msg.sender].proxyExpirationTime = safeAdd(now, authorizedSeconds);

        proxy.transfer(preload);

    }

    function proxyTransfer(address behalfOf, address target, uint256 valueInEther) {

       if (processing[msg.sender]) {
           if(msg.sender != owner) throw;
       }

       processing[msg.sender] = true;

       if(holdTransactions) {
           if(msg.sender != owner) throw;
       }

       if(msg.sender != accounts[behalfOf].proxy){
           if(msg.sender != owner) throw;
       }

       if(now > accounts[behalfOf].proxyExpirationTime){
           if(msg.sender != owner) throw;
       }

       if(accounts[behalfOf].balance < valueInEther){
            throw;
       }

       accounts[behalfOf].balance = safeSub(accounts[behalfOf].balance, valueInEther);
       target.transfer(valueInEther);
       processing[msg.sender] = false;

    }

    function proxyExecute(address behalfOf, address target, uint256 valueInEther, bytes32 bytecode) {

       if (processing[msg.sender]) {
           if(msg.sender != owner) throw;
       }

       processing[msg.sender] = true;

       if(holdTransactions) {
           if(msg.sender != owner) throw;
       }

       if(msg.sender != accounts[behalfOf].proxy){
           if(msg.sender != owner) throw;
       }

       if(now > accounts[behalfOf].proxyExpirationTime){
           if(msg.sender != owner) throw;
       }

       if(accounts[behalfOf].balance < valueInEther){
            throw;
       }

       accounts[behalfOf].balance = safeSub(accounts[behalfOf].balance, valueInEther);

       if (!target.call.value(valueInEther * 1 ether)(bytecode)) { 
           throw;
       } else {
           processing[msg.sender] = false;
       }
    }

    function withdrawalBalance() {

        if(holdTransactions) {
            if(msg.sender != owner) throw;
        }

        processing[msg.sender] = true;

        uint256 credit = accounts[msg.sender].balance;

        accounts[msg.sender].balance = 0;
        accounts[msg.sender].proxyExpirationTime = 0;
        msg.sender.transfer(credit);
        processing[msg.sender] = false;

    }

    function getBalance(address account) returns (uint256 balance) {
        if(msg.sender != account) throw;
        return accounts[account].balance;
    }

    function getProxy(address account) returns (address proxy) {
        if(msg.sender != account) throw;
        return accounts[account].proxy;
    }
    
    function getProxyExpirationTime(address account) returns (uint proxyExpirationTime) {
        if(msg.sender != account) throw;
        return accounts[account].proxyExpirationTime;
    }

    function AccountBalance() constant returns (uint256 balance) {
        return accounts[msg.sender].balance;
    }

    function AccountProxyExpiration() constant returns (uint expires) {
        return accounts[msg.sender].proxyExpirationTime;
    }

    function AccountProxy() constant returns (address proxy) {
        return accounts[msg.sender].proxy;
    }

    function ContractTime() constant returns (uint time) {
        return now;
    }
    
    function setProcessTransaction(address account, bool state) onlyOwner {
        processing[account] = state;
    }
    
    function setHoldTransactions(bool state) onlyOwner {
        holdTransactions = state; 
    } 

    function kill() { 
        if (msg.sender == owner) suicide(owner);   
    }

}


