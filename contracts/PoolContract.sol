// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PoolContract {
    address public owner;

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    // owner should be the Core contract address
    constructor() {
        owner = msg.sender;
    }

    function poolTransfer(
        address payable _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        require(address(this).balance >= _amount, "Not enough pool balance");
        require(_to != address(0), "Invalid address");
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to pool transfer");
        return sent;
    }
}
