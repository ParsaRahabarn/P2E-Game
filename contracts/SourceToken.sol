// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MatrixSourceToken is ERC20 ,Ownable{
    constructor(uint _totalSupply) ERC20("MatrixToken", "MXT") Ownable(msg.sender){
        _mint(msg.sender, _totalSupply*10 ** decimals());
    }
    function mint(address user, uint amount) public onlyOwner(){
        _mint(user, amount * 10 ** decimals());
    }
}


