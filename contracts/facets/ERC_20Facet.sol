// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "../interfaces/IERC_20.sol";
import {LibERC20} from "../libraries/LibERC20.sol";

contract ERC20 is IERC_20 {
    function name() external view override returns (string memory) {
        return LibERC20.erc20_storage().name;
    }

    function symbol() external view override returns (string memory) {
        return LibERC20.erc20_storage().symbol;
    }

    function decimal() external view override returns (uint8) {
        return LibERC20.erc20_storage().decimal;
    }

    function totalSupply() external view override returns (uint256) {
        return LibERC20.erc20_storage().totalSupply;
    }

    function balanceOf(address owner) external view returns (uint256) {
        return LibERC20.erc20_storage().balances[owner];
    }

    function transfer(
        address _to,
        uint256 _amount
    ) external override returns (bool) {
        LibERC20.transfer(msg.sender, _to, _amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external override returns (bool) {
        LibERC20._spendAllowance(_from, _to, _amount);
        LibERC20.transfer(_from, _to, _amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(
        address _spender,
        uint256 _amount
    ) external override returns (bool) {
        LibERC20.approve(msg.sender, _spender, _amount);
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(
        address _spender,
        uint256 _amount
    ) external returns (bool) {
        LibERC20._spendAllowance(msg.sender, _spender, _amount);
        return true;
    }

    function mint(
        address _owner,
        uint256 _amount
    ) external override returns (bool) {
        LibERC20.mint(_owner, _amount);
        return true;
    }
}
