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

    event Deposit(address indexed depositor, uint256 collateralAmt);
    event Borrow(address indexed borrower, uint256 debtAmt);

    error InsufficientAllowance();
    error InvalidAddress();
    error InsufficientCollateralForRequestedDebt();

    constructor(
        string memory name_,
        string memory symbol_,
        address collateralAsset_
    ) ERC20(name_, symbol_) {
        _collateralAsset = IERC20(collateralAsset_);
    }

    function deposit(uint256 collateralAmt) external {
        if (_collateralAsset.allowance(msg.sender, address(this)) < collateralAmt) {
            revert InsufficientAllowance();
        }
        _deposit(collateralAmt);
    }

    function borrow(uint256 debtAmt) external {
        uint256 debt = _calculateDebt(debtAmt);
        _borrow(debt);
    }

    function _deposit(uint256 _amt) internal {
        _vaults[msg.sender].collateralAmt += _amt;
        _collateralAsset.transferFrom(msg.sender, address(this), _amt);
        emit Deposit(msg.sender, _amt);
    }

    function _borrow(uint256 _borrowAmt) internal {

    }

    function _calculateDebt(uint256 _amt) internal view returns (uint256) {
        uint256 _borrowAmt = _borrowLimit * _amt;
        return _borrowAmt;
    }
}
