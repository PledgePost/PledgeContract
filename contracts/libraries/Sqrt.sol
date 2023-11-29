// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Sqrt {
    // Calculates the Square root of x
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
