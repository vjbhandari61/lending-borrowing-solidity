// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.32;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaulCore is ERC20 {
    struct Vault {
        uint256 collateralAmt;
        uint256 debt;
    }

    IERC20 internal _collateralAsset;
    uint256 internal _borrowLimit = 0.75 ether;
    mapping(address => Vault) internal _vaults;

    event Deposit(
        address indexed depositor,
        uint256 collateralAmt,
        uint256 borrowedAmt
    );

    error InsufficientBalance();
    error InvalidAddress();

    constructor(
        string memory name_,
        string memory symbol_,
        address collateralAsset_
    ) ERC20(name_, symbol_) {
        _collateralAsset = IERC20(collateralAsset_);
    }

    function deposit(uint256 amount) external {
        if (_collateralAsset.balanceOf(msg.sender) < amount) {
            revert InsufficientBalance();
        }
        _deposit(amount);
    }

    function _deposit(uint256 _amt) internal {
        uint256 _borrowAmt = _calculateBorrowAmt(_amt);
        _vaults[msg.sender] = Vault(_amt, _borrowAmt);

        _collateralAsset.transferFrom(msg.sender, address(this), _amt);
        super._mint(msg.sender, _borrowAmt);

        emit Deposit(msg.sender, _amt, _borrowAmt);
    }

    function _calculateBorrowAmt(uint256 _amt) internal view returns (uint256) {
        uint256 _borrowAmt = _borrowLimit * _amt;
        return _borrowAmt;
    }
}
