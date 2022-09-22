## **Access Private variables in solidity** 

All data on a smart contract can be read including private data.
Open Command Prompt and follow the steps bellow :

1) migrate the contract to Ropsten network
![](images/1.png)

2) start a truffle console that is connected to the ropsten test network
![](images/2.png)

3) get the contract and its address <br/>
![](images/3.png)

4) execute the addSomeUser() function
![](images/4.png)

5) get the state variable that is stored in slot 0 , because the first declared variable is dynamic array so the length of array is stored in slot 0
![](images/5.png)

6) array elements is stored in slots starting from hash(0)<br/>
The returning value is actually username of first User that has been pushed to array
![](images/6.png)

7) converting bytes32 username to alphabet
![](images/7.png)

8) in the next slot , the password of first user has been stored (add slot hash by 1 to access next slot)<br/>
In the next slot , username of second user has been stored and so on … 
![](images/8.png)

9) the mapping has been declared in slot 1 , so for accessing data we should calculate the hash of mapping index with this slot
![](images/9.png)

10) uint value(block.timestamp) that has mapped to index 1 (the second user that has been pushed to structure )<br/>
![](images/10_1.png)
![](images/10_2.png)


