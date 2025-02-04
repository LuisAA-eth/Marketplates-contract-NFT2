// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ConquerERC20 is ERC20, Ownable {

    constructor() ERC20("Conquer ERC20", "CONQ") Ownable(msg.sender) {}

    function mintConquerERC20(address account, uint256 value) external onlyOwner {
        _mint(account, value);
    }
   
}