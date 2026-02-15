// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultCore is ERC20 {
    struct Vault {
        uint256 collateralAmt;
        uint256 debt;
    }

    IERC20 internal _collateralAsset;
    uint256 internal _colFactorBps = 7500;
    mapping(address => Vault) internal _vaults;

    event Deposit(address indexed depositor, uint256 collateralAmt);
    event Borrow(address indexed borrower, uint256 debtAmt);
    event Repay(address indexed repayer, uint256 debtAmt);

    error InsufficientAllowance();
    error InvalidAddress();
    error InsufficientCollateralForRequestedDebt();
    error InsufficientLiquidityInPool();
    error CannotBorrowMoreThanDebtCeiling();
    error InvalidAmtRequested();

    constructor(
        string memory name_,
        string memory symbol_,
        address collateralAsset_
    ) ERC20(name_, symbol_) {
        _collateralAsset = IERC20(collateralAsset_);
    }

    function deposit(uint256 collateralAmt) external {
        if(_collateralAsset.allowance(msg.sender, address(this)) < collateralAmt) {
            revert InsufficientAllowance();
        }
        _deposit(collateralAmt);
    }

    function borrow(uint256 debtAmt) external {
        // if(_collateralAsset.balanceOf(address(this)) >= debtAmt){ revert InsufficientLiquidityInPool(); }
        _borrow(debtAmt);
    }

    function repay(uint256 debtAmt) external {
        // if(_collateralAsset.allowance(msg.sender, address(this)) < debtAmt) {
        //     revert InsufficientAllowance();
        // }
        _repay(debtAmt);
    }

    function calculateDebt(uint256 collateralAmt) public view returns (uint256) {
        return _calculateDebt(collateralAmt);
    }

    function getUserVault(address user) public view returns(Vault memory) {
        return _vaults[user];
    } 

    function _deposit(uint256 _collateral) internal {
        _vaults[msg.sender].collateralAmt += _collateral;
        _collateralAsset.transferFrom(msg.sender, address(this), _collateral);

        emit Deposit(msg.sender, _collateral);
    }

    function _borrow(uint256 _debtAmt) internal {
        Vault storage vault = _vaults[msg.sender];
        uint256 maxBorrowable = _calculateDebt(vault.collateralAmt);

        if (vault.debt + _debtAmt >= maxBorrowable) {
            revert CannotBorrowMoreThanDebtCeiling();
        }
        vault.debt += _debtAmt;
        _mint(msg.sender, _debtAmt);

        emit Borrow(msg.sender, _debtAmt);
    }

    function _repay(uint256 _debtAmt) internal {
        Vault storage vault = _vaults[msg.sender];
        if (vault.debt < _debtAmt) {
            revert InvalidAmtRequested();
        }

        vault.debt -= _debtAmt;
        _burn(msg.sender, _debtAmt);

        emit Repay(msg.sender, _debtAmt);
    }

    function _calculateDebt(uint256 _collateral) internal view returns(uint256) {
        uint256 max = ( _collateral * _colFactorBps ) / 10_000;
        return max;
    }
}
