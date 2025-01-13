// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Token is ERC20, Ownable {

    // Initial supply is specified in the constructor (in tokens, not wei)
    constructor(uint256 initialSupply) Ownable(msg.sender) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // Mint new tokens (only the owner can call this)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount * 10 ** decimals());
    }

    // Burn tokens (any token holder can burn their own tokens)
    function burn(uint256 amount) external {
        _burn(msg.sender, amount * 10 ** decimals());
    }

    // Override decimals if needed (default is 18)
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
