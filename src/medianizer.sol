pragma solidity ^0.4.8;

import 'ds-value/value.sol';

contract Medianizer is DSThing {
    mapping (uint8 => DSValue) public values;
    uint8 public next = 1;

    function set(DSValue wat) auth {
        values[next] = wat;
        next++;
    }

    function read() constant returns (bytes32) {
        if (next <= 1) throw;

        bytes32[] memory wuts = new bytes32[](next - 1);
        uint8 ctr = 0;
        for (uint8 i = 1; i < next; i++) {
            bytes32 wut = values[i].read();
            if (ctr == 0 || wut >= wuts[ctr - 1]) {
                wuts[ctr] = wut;
            } else {
                uint8 j = 0;
                while (wut >= wuts[j]) {
                    j++;
                }
                for (uint8 k = ctr; k > j; k--) {
                    wuts[k] = wuts[k - 1];
                }
                wuts[j] = wut;
            }
            ctr++;
        }

        if (ctr % 2 == 0) {
            uint128 val1 = uint128(wuts[(ctr / 2) - 1]);
            uint128 val2 = uint128(wuts[ctr / 2]);
            return bytes32(wdiv(incr(val1, val2), 2 ether));
        } else {
            return wuts[(ctr - 1) / 2];
        }
    }

}