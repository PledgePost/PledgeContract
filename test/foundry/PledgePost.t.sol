// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "../../contracts/PledgePost.sol";

contract PledgePostTest is Test {
    PledgePost pledgePost;

    function setUp() public {
        pledgePost = new PledgePost();
        // Initialize your contract here if needed
    }

    function test_PostArticle() public {
        // Call the postArticle function
        string
            memory article = "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq";
        pledgePost.postArticle(article);
        // Check the result using assertEq or similar functions
        assertEq(
            pledgePost.getAuthorArticle(address(this), 0).content,
            article
        );
    }
}
