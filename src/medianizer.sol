pragma solidity ^0.4.8;

import 'ds-cache/cache.sol';

contract Medianizer is DSCache {
    mapping (bytes12 => DSValue) public values;
    bytes12 public next = 0x1;
    
    function set(DSValue wat) auth {
        bytes12 nextId = bytes12(uint96(next) + 1);
        assert(nextId != 0x0);
        values[next] = wat;
        next = nextId;
    }

    function poke() auth {
        val = compute();
        has = true;
    }

    function poke(bytes32) {
        poke();
    }

    function prod(uint128 Zzz) {
        prod(0, Zzz);
    }

    function compute() internal constant returns (bytes32) {
        if (next <= 0x1) throw;

        bytes32[] memory wuts = new bytes32[](uint96(next) - 1);
        uint96 ctr = 0;
        for (uint96 i = 1; i < uint96(next); i++) {
            bytes32 wut = values[bytes12(i)].read();
            if (ctr == 0 || wut >= wuts[ctr - 1]) {
                wuts[ctr] = wut;
            } else {
                uint96 j = 0;
                while (wut >= wuts[j]) {
                    j++;
                }
                for (uint96 k = ctr; k > j; k--) {
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
