// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

import {Merkle} from "../src/AbegToken.sol";

contract AbegTest is Test {
    using stdJson for string;
    Merkle public merkle;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint tokenID;
        uint amount;
    }
    Result public result;
    User public user;
    bytes32 root =
        0xd5b9d6af00fc4a5a600ef45e59340c5a661774241772aa6478e4c2ca800c2122;
    address user1 = 0xcB00517eEaC61c467324282f9ff9004f652DbBed;

    function setUp() public {
        merkle = new Merkle(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_data.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );
        user.user = vm.parseJsonAddress(
            dataJson,
            string.concat(".", vm.toString(user1), ".address")
        );
        user.amount = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".amount")
        );

        user.tokenID = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".tokenID")
        );
        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {
        bool success = merkle.claim(
            user.user,
            user.amount,
            user.tokenID,
            result.proof
        );
        assertTrue(success);
    }

    function testAlreadyClaimed() public {
        merkle.claim(user.user, user.amount, user.tokenID, result.proof);
        vm.expectRevert("already claimed");
        merkle.claim(user.user, user.amount, user.tokenID, result.proof);
    }

    function testIncorrectProof() public {
        bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        merkle.claim(
            user.user,
            user.amount,
            user.tokenID,
            fakeProofleaveitleaveit
        );
    }
}
