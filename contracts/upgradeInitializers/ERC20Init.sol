// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {LibERC20} from "../libraries/LibERC20.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {IERC165} from "../interfaces/IERC165.sol";
import {IERC20} from "../interfaces/IERC_20.sol";

// It is exapected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

contract ERC20Init {
    struct InitArgs {
        string name;
        string symbol;
        uint8 decimal;
        uint256 initialSupply;
        address initialHolder;
    }

    // You can add parameters to this function in order to pass in
    // data to set your own state variables
    function init(InitArgs memory args) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
        ds.supportedInterfaces[type(IERC20).interfaceId] = true;

        LibERC20.ERC20Storage storage s = LibERC20.erc20_storage();
        require(!s.initialized, "ERC20: already initialized");

        s.name = args.name;
        s.symbol = args.symbol;
        s.decimal = args.decimal;
        s.initialized = true;

        if (args.initialSupply > 0) {
            require(
                args.initialHolder != address(0),
                "ERC20: Mint to zero address"
            );
            LibERC20.mint(args.initialHolder, args.initialSupply);
        }
        // add your own state variables
        // EIP-2535 specifies that the `diamondCut` function takes two optional
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface
    }
}
