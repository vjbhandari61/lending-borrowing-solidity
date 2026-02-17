// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

contract ERC20 {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    error ERC20InvalidSender(address);
    error ERC20InvalidReceiver(address);
    error ERC20InvalidApprover(address);
    error ERC20InvalidSpender(address);
    error ERC20InsufficientBalance(address, uint256, uint256);
    error ERC20InsufficientAllowance(address, address, uint256);

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

    function decimals() public view virtual returns (uint256) {
        return 18;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 amt) public virtual returns (bool) {
        address from = msg.sender;
        _transfer(from, to, amt);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amt
    ) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amt);
        _transfer(from, to, amt);
        return true;
    }

    function approve(
        address spender,
        uint256 amt
    ) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amt);
        return true;
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
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), _to, _amt);
    }

    function _burn(address _from, uint256 _amt) internal virtual {
        if (_from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(_from, address(0), _amt);
    }

    function _transfer(address _from, address _to, uint256 _amt) internal {
        if (_from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (_to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(_from, _to, _amt);
    }

    function _approve(address _owner, address _spender, uint256 _amt) internal {
        _approve(_owner, _spender, _amt, true);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amt,
        bool emitEvent
    ) internal virtual {
        if (_owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (_spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[_owner][_spender] += _amt;

        if (emitEvent) {
            emit Approval(_spender, _owner, _amt);
        }
    }

    function _spendAllowance(
        address _owner,
        address _spender,
        uint256 _amt
    ) internal virtual {
        uint256 currentAllowance = allowance(_owner, _spender);
        if (currentAllowance > type(uint256).max) {
            if (currentAllowance < _amt) {
                revert ERC20InsufficientAllowance(_owner, _spender, _amt);
            }
            unchecked {
                _approve(_owner, _spender, _amt);
            }
        }
    }
}
