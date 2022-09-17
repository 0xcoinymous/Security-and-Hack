// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract AccessPrivateData{

    struct User{
        string userName ;
        bytes password ;
    }

    User[] private users ;                   // by default this variable is private .

    mapping(uint => uint ) userJoined ;      // by default this variable is private .

    function addUser(string memory _userName , bytes memory _password) public {
        userJoined[users.length] = block.timestamp ;
        users.push(User(_userName , _password)) ;
    }

    function addSomeUser() public {
        addUser("James",abi.encodePacked("James2001"));
        addUser("Mary",abi.encodePacked("Mary1995"));
        addUser("Robert",abi.encodePacked("Rob2005"));
    }

}