// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { IERC20MintableBurnable } from '../interfaces/IERC20MintableBurnable.sol';
import { TokenLinker } from './TokenLinker.sol';

contract TokenLinkerMintBurn is TokenLinker {
    error MintFailed();
    error BurnFailed();

    address public immutable tokenAddress;

    constructor(address gatewayAddress_, address tokenAddress_) TokenLinker(gatewayAddress_) {
        tokenAddress = tokenAddress_;
    }

    function _giveToken(address to, uint256 amount) internal override {
        (bool success, bytes memory returnData) = tokenAddress.call(
            abi.encodeWithSelector(IERC20MintableBurnable.mint.selector, to, amount)
        );
        bool transferred = success && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));

        if (!transferred || tokenAddress.code.length == 0) revert MintFailed();
    }

    function _takeToken(address from, uint256 amount) internal override {
        (bool success, bytes memory returnData) = tokenAddress.call(
            abi.encodeWithSelector(IERC20MintableBurnable.burn.selector, from, amount)
        );
        bool transferred = success && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));

        if (!transferred || tokenAddress.code.length == 0) revert('BurnFailed()');
    }
}
