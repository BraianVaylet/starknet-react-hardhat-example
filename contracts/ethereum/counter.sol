// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IStarknetCore.sol";

contract Gateway {
    address public initialEndpointGatewaySetter;
    uint256 public endpointGateway;
    IStarknetCore public starknetCore;
    uint256 constant ENDPOINT_SELECTOR =
        1103862085463543142437905028712144613313501480399588993098014957443480417719; // `python scripts/selector.py EVMtoSN`

    bool public isOnStarkNet; // Counter start on EVM blockchain
    uint256 counter;

    constructor(address _starknetCore, uint256 _endpointGateway) {
        starknetCore = IStarknetCore(_starknetCore);
        endpointGateway = _endpointGateway;
    }

    function getCounter() public returns(uint256) {
        require(!isOnStarkNet, "Counter is on StarkNet, can't count");

        return counter;
    }

    /* 
        @dev Set the new value to counter if new value is old value + 1
    */
    function count() external {
        uint256 _counter = getCounter();
        unchecked {
            _counter += 1;
        }
        counter = _counter;
    }

    function transferToStarkNet() external
        uint256[] memory payload = new uint256[](1);

        // build deposit message payload
        payload[0] = getCounter();

        // send message
        starknetCore.sendMessageToL2(
            endpointGateway,
            ENDPOINT_GATEWAY_SELECTOR,
            payload
        );

        isOnStarkNet = true;
    }

    function transferFromStarkNet(
        uint256 _counter
    ) external {
        require(isOnStarkNet, "Counter is not on StarkNet, can't transfer from");
        uint256[] memory payload = new uint256[](1);

        // build message payload
        payload[0] = _counter;

        // consum withdraw message
        starknetCore.consumeMessageFromL2(this, payload);

        // save new counter state
        counter = _counter;
        isOnStarkNet = false;
    }
