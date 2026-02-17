// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

interface IDai {
    function totalSupply() external view returns (uint256);
        
    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amt) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function version() external pure returns(uint256);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

    function push(address to, uint256 amount) external;

    function pull(address from, address to, uint256 amount) external;
}