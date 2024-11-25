// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract USDB is ERC20 {
    constructor(uint amount) ERC20("USD BLAST", "USDB") {
        _mint(msg.sender, amount * 10 ** decimals());
    }
    function mint(address user, uint amount) public {
        _mint(user, amount * 10 ** decimals());
    }
}
