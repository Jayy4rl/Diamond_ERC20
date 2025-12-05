// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

library LibERC20 {
    bytes32 constant STORAGE_POSITION = keccak256("erc20.storage");

    struct ERC20Storage {
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        string name;
        string symbol;
        uint8 decimal;
        uint256 totalSupply;
        bool initialized;
    }

    function erc20_storage() internal pure returns (ERC20Storage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function transfer(address _from, address _to, uint256 _amount) public {
        if (_to == address(0)) {
            revert("Cannot transfer to zero address");
        }
        if (_from == address(0)) {
            revert("Cannot transfer from zero address");
        }

        ERC20Storage storage s = erc20_storage();

        if (s.balances[_from] <= _amount) {
            revert("Cannot transfer greater than balance");
        }

        s.balances[_from] -= _amount;
        s.balances[_to] += _amount;
    }

    function approve(address _from, address _spender, uint256 _amount) public {
        if (_spender == address(0)) {
            revert("Cannot use zero address");
        }
        if (_from == address(0)) {
            revert("Cannot spend from zero address");
        }

        ERC20Storage storage s = erc20_storage();

        s.allowances[_spender][_from] += _amount;
    }

    function _spendAllowance(
        address _from,
        address _spender,
        uint256 _amount
    ) public {
        if (_from == address(0)) {
            revert("Cannot spend from zero address");
        }
        if (_spender == address(0)) {
            revert("Invalid address");
        }

        ERC20Storage storage s = erc20_storage();
        if (s.allowances[_spender][_from] < _amount) {
            revert("Cannot spend amount greater than allowance");
        }

        s.allowances[_spender][_from] -= _amount;
    }

    function mint(address _to, uint256 _amount) public {
        if (_to == address(0)) {
            revert("Cannot mint to zero address");
        }

        ERC20Storage storage s = erc20_storage();

        s.totalSupply += _amount;
        s.balances[_to] += _amount;
    }
}
