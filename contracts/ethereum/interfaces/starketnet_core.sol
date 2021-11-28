// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStarknetCore {
    mapping(bytes32 => uint256) public l2ToL1Messages;
    mapping(bytes32 => uint256) public l1ToL2Messages;

    /**
      Sends a message to an L2 contract.
    */
    function sendMessageToL2(
        uint256 to_address,
        uint256 selector,
        uint256[] calldata payload
    ) external;

    /**
      Consumes a message that was sent from an L2 contract.
    */
    function consumeMessageFromL2(
        uint256 fromAddress,
        uint256[] calldata payload
    ) external;
}
