// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library QF {
    // get sum of sqrt x
    // get squared sum of sqrt x
    // sum of sqrt
    // matching pool
    // calculate matching * suquare sum of sqrt x / total squared sum of sqrt x

    // Calculates the square root of x
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
