// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {DaiToken} from "../src/Dai.sol";
import {IDai} from "../src/interfaces/IDai.sol";

contract DaiTokenTest is Test {
    DaiToken public dai;

    address owner = vm.addr(1);
    address alice = vm.addr(2);
    address bob = vm.addr(3);

    function setUp() public {
        dai = new DaiToken();
    }

    function _mint_helper(address account, uint256 amount) public {
        dai.mint(account, amount);
    }

    function test_Mint() public {        
        vm.startPrank(owner);

        dai.mint(alice, 20 ether);

        vm.stopPrank();
        
        assertEq(dai.balanceOf(alice), 20 ether);
        assertEq(dai.totalSupply(), 20 ether);
    }

    function test_Burn() public {
        vm.startPrank(owner);
        _mint_helper(alice, 20 ether);

        dai.burn(alice, 15 ether);

        vm.stopPrank();

        assertEq(dai.balanceOf(alice), 5 ether);
        assertEq(dai.totalSupply(), 5 ether);
    }

    function test_Push() public {
        vm.startPrank(alice);
        _mint_helper(alice, 20 ether);

        dai.push(bob, 5 ether);

        vm.stopPrank();

        assertEq(dai.balanceOf(alice), 15 ether);
        assertEq(dai.balanceOf(bob), 5 ether);
        assertEq(dai.totalSupply(), 20 ether);
    }

    function test_Pull() public {
        vm.startPrank(owner);
        _mint_helper(alice, 20 ether);

        dai.pull(alice, bob, 5 ether);

        vm.stopPrank();

        assertEq(dai.balanceOf(alice), 15 ether);
        assertEq(dai.balanceOf(bob), 5 ether);
        assertEq(dai.totalSupply(), 20 ether);
    }

    function test_Approve() public {
        vm.startPrank(alice);
        _mint_helper(alice, 20 ether);

        dai.approve(bob, 20 ether);

        vm.stopPrank();

        assertEq(dai.balanceOf(alice), 20 ether);
        assertEq(dai.balanceOf(bob), 0);
        assertEq(dai.totalSupply(), 20 ether);
        assertEq(dai.allowance(alice, bob), 20 ether);
    }

    function test_Name() public view {
        assertEq(dai.name(), "Dai Stablecoin");
    }

    function test_Symbol() public view {
        assertEq(dai.symbol(), "DAI");
    }

    function test_Decimals() public view {
        assertEq(dai.decimals(), 18);
    }
     
    function test_Version() public view {
        assertEq(dai.version(), 1);
    }
}
