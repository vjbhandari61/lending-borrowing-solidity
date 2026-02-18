// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {IDai} from "../interfaces/IDai.sol";

contract SimpleProtocol {
    IDai private _dai;
    uint256 private _colFactorBps;

    uint256 private _totalCollateral;
    uint256 private _totalDebt;

    struct Vault {
        uint256 _collateral;
        uint256 _debt;
    }

    mapping(address => Vault) private vaults;

    event Deposit(address indexed account, uint256 collateral);
    event Borrow(address indexed account, uint256 debt);
    event Repay(address indexed account, uint256 repaidDebt);

    error SProtocol01InvalidCollateralValueReceieved(address, uint256);
    error SProtocol02InvalidDebtValueRequested(address, uint256);
    error SProtocol03InsufficientCollateralForRequestedDebt(address, uint256, uint256);
    error SProtocol04InvalidValue(uint256);
    error SProtocol05InvalidDebtValueReceived(address, uint256);

    constructor(address daiToken, uint256 colFactorPercentage) {
        _dai = IDai(daiToken);
        _colFactorBps = colFactorPercentage * 100;
    }

    function deposit() external payable {
        uint256 collateral = msg.value;
        if(collateral <= 0) { revert SProtocol01InvalidCollateralValueReceieved(msg.sender, collateral); }
        _deposit(msg.sender, collateral);
    }

    function borrow(uint256 debt) external {
        if(debt <= 0) { revert SProtocol02InvalidDebtValueRequested(msg.sender, debt); }
        _borrow(msg.sender, debt);
    }

    function repay(uint256 debt) external {
        if(debt <= 0) { revert SProtocol04InvalidValue(debt); }
        _repay(msg.sender, debt);
    }

    function _deposit(address _account, uint256 _collateral) internal {
        vaults[_account]._collateral += _collateral; 
        _totalCollateral += _collateral;

        emit Deposit(_account, _collateral);
    }

    function _borrow(address _account, uint256 _debt) internal {
        Vault storage vault = vaults[_account];
        uint256 _maxDebt = _calculateMaxDebt(vault._collateral);
        
        if(_maxDebt <= (vault._debt + _debt)) { revert SProtocol03InsufficientCollateralForRequestedDebt(_account, _maxDebt, vault._debt); }
        vault._debt += _debt;
        _totalDebt += _debt;

        _dai.mint(_account, _debt);
        emit Borrow(_account, _debt);
    }

    function _repay(address _account, uint256 _debt) internal {
        Vault storage vault = vaults[_account];
        if(vault._debt < _debt) { revert SProtocol05InvalidDebtValueReceived(_account, _debt); }
        vault._debt -= _debt;
        _totalDebt -= _debt;

        _dai.burn(_account, _debt);
        emit Repay(_account, _debt);
    }

    function _calculateMaxDebt(uint256 _collateral) internal view returns(uint256) {
        uint256 maxDebt = ( _collateral * _colFactorBps ) / 10_000;
        return maxDebt;
    }
}