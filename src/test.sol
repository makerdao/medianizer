pragma solidity ^0.4.8;

import "ds-test/test.sol";
import 'ds-cache/cache.sol';

import './medianizer.sol';


contract Test is DSTest {
    Medianizer m;
    Medianizer m2;
    DSCache c1;
    DSCache c2;
    DSCache c3;
    DSCache c4;
    DSCache c5;
    uint128 zzz = uint128(now + 1000);

    function setUp() {
        m = new Medianizer();

        c1 = new DSCache();
        c2 = new DSCache();
        c3 = new DSCache();
        c4 = new DSCache();
        c5 = new DSCache();

        c1.prod(5 ether, zzz);
        c2.prod(10 ether, zzz);
        c3.prod(7 ether, zzz);
        c4.prod(8 ether, zzz);
        c5.prod(1 ether, zzz);
    }

    function testOneValue() {
        m.set(c1);
        
        bytes32 res = m.read();

        assertEqDecimal(uint256(res), 5 ether, 18);
    }

    function testTwoValues() {
        m.set(c1);
        m.set(c2);
        
        bytes32 res = m.read();

        assertEqDecimal(uint256(res), 7.5 ether, 18);
    }

    function testThreeValues() {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        
        bytes32 res = m.read();

        assertEqDecimal(uint256(res), 7 ether, 18);
    }

    function testFourValues() {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        m.set(c4);
        
        bytes32 res = m.read();

        assertEqDecimal(uint256(res), 7.5 ether, 18);
    }

    function testFiveValues() {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        m.set(c4);
        m.set(c5);
        
        bytes32 res = m.read();

        assertEqDecimal(uint256(res), 7 ether, 18);
    }

    function testFiveValuesDifferentOrder() {
        m.set(c3);
        m.set(c2);
        m.set(c5);
        m.set(c4);
        m.set(c1);
        
        bytes32 res = m.read();

        assertEqDecimal(uint256(res), 7 ether, 18);
    }

    function testRecursiveMedianizer() {
        m2 = new Medianizer();

        m.set(c1);
        m.set(c2);
        m.set(c3);

        m2.set(c3);
        m2.set(c4);

        bytes32 res2 = m2.read();

        assertEqDecimal(uint256(res2), 7.5 ether, 18);

        m.set(DSValue(m2));

        bytes32 res = m.read();

        assertEqDecimal(uint256(res), 7.25 ether, 18);
    }

    function testFailNoValues() {
        m.read();
    }

    function testFailOneVoid() {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        
        c1.void();

        m.read();
    }
}
