// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// create Interface for PoolContract
interface IPoolContract {
    function poolTransfer(
        address payable _to,
        uint256 _amount
    ) external returns (bool);
}
