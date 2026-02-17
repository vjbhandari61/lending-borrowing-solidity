// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "./token/ERC20.sol";

contract DaiToken is ERC20 {
    constructor() ERC20("Dai Stablecoin", "DAI"){}

    function version() external pure returns(uint256) {
        return 1;
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        require(balanceOf(account) >= amount, "Dai: Insufficient Balance");
        _burn(account, amount);
    }

    function push(address to, uint256 amount) external {
        transfer(to, amount);
    }

    function pull(address from, address to, uint256 amount) external {
        transferFrom(from, to, amount);
    }
}