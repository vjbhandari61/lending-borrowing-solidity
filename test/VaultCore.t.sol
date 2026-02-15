// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {VaultCore} from "../src/VaultCore.sol";
import {MockUSDC} from "../src/mocks/mockUSDC.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultCoreTest is Test {
    VaultCore public vault_core;
    MockUSDC public mock_usdc;

    address public mockUSDC;
    address owner = vm.addr(1);

    function setUp() public {
        mock_usdc = new MockUSDC(owner, owner);
        mockUSDC = address(mock_usdc);
        vault_core = new VaultCore("Vijay Token", "VJX", mockUSDC);
    }

    function test_Deposit() public {
        // mockUSDC.mint(owner, 30 ether);
        
        vm.startPrank(owner);
        IERC20(mockUSDC).approve(address(this), 30 ether);

        vault_core.deposit(30 ether);
        VaultCore.Vault memory vault = vault_core.getUserVault(owner);
        vm.stopPrank();

        assertEq(vault.collateralAmt, 30 ether);
    }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
