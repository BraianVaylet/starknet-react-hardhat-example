# Declare this file as a StarkNet contract and set the required
# builtins.
%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
#from starkware.cairo.common.Uint256 import Uint256
from starkware.starknet.common.messages import send_message_to_l1
from starkware.cairo.common.math import assert_le

## Represents an integer in the range [0, 2^256).
#struct Uint256:
#    # The low 128 bits of the value.
#    member low : felt
#    # The high 128 bits of the value.
#    member high : felt
#end

# l1 gateway address
@storage_var
func l1_gateway() -> (res : felt):
end

# keep track of the counter
@storage_var
func counter() -> (res : felt):
end

# keep track of the counter
@storage_var
func isOnStarkNet() -> (res : felt):
end

# constructor
@external
func initialize{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _l1_gateway : felt):
    let (is_initialized) = l1_gateway.read()
    assert is_initialized = 0

    l1_gateway.write(_l1_gateway)
    isOnStarkNet.write(0)

    return ()
end

@external
func count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (count : felt):
    let (onStarkNet) = isOnStarkNet.read()
    assert onStarkNet = 1
    let (currentCounter) = counter.read()

    counter.write(currentCounter+1)
    return (count=currentCounter+1)
end

@view
func getCounter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (count : felt, on_stark_net: felt):
    let (count) = counter.read()
    let (is_on_stark_net) = isOnStarkNet.read()
    return (count=count, on_stark_net=is_on_stark_net)
end

@l1_handler
func EVMtoSN{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        from_address : felt, _counter : felt):
    let (onStarkNet) = isOnStarkNet.read()
    assert onStarkNet = 0
    let (res) = l1_gateway.read()
    assert from_address = res

    let (currentCounter) = counter.read()
    assert_le(currentCounter, _counter)

    counter.write(_counter)
    isOnStarkNet.write(1)

    return ()
end

@external
func SNtoEVM{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _l1_token_address : felt):
    let (onStarkNet) = isOnStarkNet.read()
    assert onStarkNet = 1
    let (l1_gateway_address) = l1_gateway.read()
    let (currentCounter) = counter.read()

    let (message_payload : felt*) = alloc()
    assert message_payload[0] = currentCounter

    send_message_to_l1(to_address=l1_gateway_address, payload_size=1, payload=message_payload)

    isOnStarkNet.write(0)
    return ()
end
