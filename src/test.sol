pragma solidity ^0.4.8;

import "ds-test/test.sol";
import "ds-value/value.sol";

import './medianizer.sol';

contract Test is DSTest {
    Medianizer m;
    DSValue c1;
    DSValue c2;
    DSValue c3;
    DSValue c4;
    DSValue c5;

    function setUp() {
        m = new Medianizer();

        c1 = new DSValue();
        c2 = new DSValue();
        c3 = new DSValue();
        c4 = new DSValue();
        c5 = new DSValue();

        c1.poke(5 ether);
        c2.poke(10 ether);
        c3.poke(7 ether);
        c4.poke(8 ether);
        c5.poke(1 ether);
    }
    
    function testNoValues() {
        m.poke();

        assertHasNoValue(m);
    }

    function testOneValue() {
        m.set(c1);
        
        m.poke();

        assertHasValue(m, 5 ether);
    }

    function testTwoValues() {
        m.set(c1);
        m.set(c2);
        
        m.poke();

        assertHasValue(m, 7.5 ether);
    }

    function testThreeValues() {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        
        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testFourValues() {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        m.set(c4);
        
        m.poke();

        assertHasValue(m, 7.5 ether);
    }

    function testFiveValues() {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        m.set(c4);
        m.set(c5);
        
        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testRearrangeValues() {
        m.set(c1);
        m.set(c2);

        m.poke();

        assertEq(m.next(), bytes12(3));
        assertHasValue(m, 7.5 ether);

        m.unset(bytes12(2));
        m.setNext(2);

        m.poke();

        assertEq(m.next(), bytes12(2));
        assertHasValue(m, 5 ether);

        m.set(c2);
        m.poke();

        assertEq(m.next(), bytes12(3));
        assertHasValue(m, 7.5 ether);
    }

    function testFiveValuesDifferentOrder() {
        m.set(c3);
        m.set(c2);
        m.set(c5);
        m.set(c4);
        m.set(c1);

        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testOneOfThreeVoid() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        c1.void();

        m.poke();

        assertHasValue(m, 8.5 ether);
    }

    function testTwoOfThreeVoid() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        c1.void();
        c2.void();

        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testAllThreeVoid() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        c1.void();
        c2.void();
        c3.void();

        m.poke();

        assertHasNoValue(m);
    }

    function testBelowMinimum() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.setMin(2);

        c1.void();
        c2.void();

        m.poke();

        assertHasNoValue(m);
    }

    function testEqualToMinimum() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.setMin(1);

        c1.void();
        c2.void();

        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testAboveMinimum() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.setMin(2);

        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testRecursiveMedianizer() {
        Medianizer m2 = new Medianizer();

        m.set(c1);
        m.set(c2);
        m.set(c3);

        m2.set(c3);
        m2.set(c4);

        m2.poke();
        assertHasValue(m2, 7.5 ether);

        m.set(DSValue(m2));
        
        m.poke();
        assertHasValue(m, 7.25 ether);
    }

    function testUnsetPos() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.unset(bytes12(2));

        m.poke();

        assertHasValue(m, 6 ether);
    }

    function testUnsetWat() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.unset(c2);

        m.poke();

        assertHasValue(m, 6 ether);
    }

    function testSetPos() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.set(2, c5);

        m.poke();

        assertHasValue(m, 5 ether);
    }

    function testSetPosAndSetAgain() {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.set(2, c5);

        m.set(c2);
    }

    function testNoValueWhenNoPoke() {
        m.set(c1);

        assertHasNoValue(m);
    }

    function testDefaultMinimumIsOne() {
        assertEq(uint(m.min()), uint(1));
    }

    function testFailSetPosZero() {
        m.set(0, c1);
    }

    function testFailSetMinZero() {
        m.setMin(0);
    }

    function testFailAddingDuplicated() {
        m.set(c1);
        m.set(c1);
    }

    // helper functions
    function assertHasNoValue(Medianizer med) internal {
        var (res, has) = med.peek();
        assert(!has);
    }
    function assertHasValue(Medianizer med, uint value) internal {
        var (res, has) = med.peek();
        assert(has);
        assertEqDecimal(uint256(res), value, 18);

        var resRead = med.read();
        assertEqDecimal(uint256(resRead), value, 18);
    }
}
