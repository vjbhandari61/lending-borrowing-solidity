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
        vault_core = new VaultCore("My Token", "MTC", mockUSDC);
    }

    function _deposit_helper() internal {
        IERC20(mockUSDC).approve(address(vault_core), 30 ether);
        vault_core.deposit(30 ether);
    }

    function _borrow_helper() internal {
        vault_core.borrow(20 ether);
    }

    function _repay_helper() internal {
        vault_core.repay(15 ether);
    }

    function test_Deposit() public {        
        vm.startPrank(owner);
        _deposit_helper();
        uint256 collateralAmt = vault_core.getUserVault(owner).collateralAmt;
        vm.stopPrank();
        assertEq(collateralAmt, 30 ether);
    }

    function test_Borrow() public {
        vm.startPrank(owner);
        _deposit_helper();
        _borrow_helper();
        uint256 debt = vault_core.getUserVault(owner).debt;
        vm.stopPrank();
        assertEq(debt, 20 ether);
    }

    function test_Repay() public {
        vm.startPrank(owner);
        _deposit_helper();
        _borrow_helper();
        _repay_helper();

        VaultCore.Vault memory vault = vault_core.getUserVault(owner);
        vm.stopPrank();

        assertEq(vault.collateralAmt, 30 ether);
        assertEq(vault.debt, 5 ether);
    }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
