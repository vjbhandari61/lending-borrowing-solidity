// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

contract ERC20 {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approve(
        address indexed spender,
        address indexed owner,
        uint256 amount
    );

    error ERC20InvalidAddress(address);
    error ERC20InsufficientBalance(address, uint256, uint256);

    constructor(string memory name__, string memory symbol__) {
        _name = name__;
        _symbol = symbol__;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function _update(address _from, address _to, uint256 _amt) internal {
        if (_from == address(0)) {
            _totalSupply += _amt;
        } else {
            uint256 fromBalance = _balances[_from];
            if (fromBalance < _amt) {
                revert ERC20InsufficientBalance(_from, fromBalance, _amt);
            }
            unchecked {
                _balances[_from] = fromBalance - _amt;
            }
        }

        if (_to == address(0)) {
            unchecked {
                _totalSupply -= _amt;
            }
        } else {
            unchecked {
                _balances[_to] += _amt;
            }
        }

        emit Transfer(_from, _to, _amt);
    }

    function _mint(address _to, uint256 _amt) internal virtual {
        if (_to == address(0)) {
            revert ERC20InvalidAddress(address(0));
        }
        _update(address(0), _to, _amt);
    }

    function _burn(address _from, uint256 _amt) internal virtual {
        if (_from == address(0)) {
            revert ERC20InvalidAddress(address(0));
        }
        _update(_from, address(0), _amt);
    }

    function _tranfer(address _from, address _to, uint256 _amt) internal {
        if (_from == address(0)) {
            revert ERC20InvalidAddress(address(0));
        }
        if (_to == address(0)) {
            revert ERC20InvalidAddress(address(0));
        }
        _update(_from, _to, _amt);
    }
}
