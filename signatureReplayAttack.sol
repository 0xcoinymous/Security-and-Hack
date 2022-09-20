// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// Signing messages off-chain and having a contract that requires that signature before executing a function
// is a useful technique but same signature can be used multiple times to execute a function .
// by signing messages with nonce and address of the contract , this attack no longer works .

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";

contract unsecuredMultiSigWallet {
    using ECDSA for bytes32;   // used to verify that a message was signed by the holder of the private keys of a given address.

    address[3] public owners;

    constructor(address[3] memory _owners) payable {
        owners = _owners;
    }

    function deposit() external payable {}

    function transfer(address _to, uint _amount, bytes[3] memory _sigs ) external {
        bytes32 txHash = keccak256(abi.encodePacked(_to, _amount));
        require(validateSigs(_sigs, txHash), "invalid signatures");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, " send Ether failed ");
    }


    function validateSigs(bytes[3] memory _sigs, bytes32 _txHash) private view returns (bool){
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash(); // Returns an Ethereum Signed Message corresponding to the current hash

        for (uint i = 0; i < _sigs.length; i++) {
            address signer = ethSignedHash.recover(_sigs[i]);

            if (!(signer == owners[i])) {
                return false;
            }
        }

        return true;
    }
}

// here the attacker can call transfer function multiple times with a [2]signature for a transaction 
// to solve this problem , we use nounce to prevent a transaction from double running 
// also this wallet may have multiple contracts to store Eth , so attacker can call transfer function in 
// every wallet contranct so to prevent this , sign the message with the address of wallet contract in addition to nonce 

contract securedMultiSigWallet {
    using ECDSA for bytes32;

    address[3] public owners;
    mapping(bytes32 => bool) public executed;

    constructor(address[2] memory _owners) payable {
        owners = _owners;
    }

    function deposit() external payable {}

    function transfer( address _to, uint _amount, uint _nonce, bytes[3] memory _sigs ) external {
        bytes32 txHash = keccak256(abi.encodePacked(address(this), _to, _amount, _nonce));
        require(!executed[txHash], "tx executed");
        require(validateSigs(_sigs, txHash), "invalid signatures");

        executed[txHash] = true;

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }


    function validateSigs(bytes[3] memory _sigs, bytes32 _txHash) private view returns (bool) {
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();

        for (uint i = 0; i < _sigs.length; i++) {
            address signer = ethSignedHash.recover(_sigs[i]);

            if (!(signer == owners[i])) {
                return false;
            }
        }

        return true;
    }
}

