/// medianizer.t.sol - tests for medianizer.sol

// Copyright (C) 2017, 2018  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.24;

import "ds-test/test.sol";
import "ds-value/value.sol";

import "./medianizer.sol";

contract FakePerson {
    Medianizer m;

    constructor(Medianizer m_) public {
        m = m_;
    }

    function set(address wat) public {
        m.set(wat);
    }

    function set(bytes12 pos, address wat) public {
        m.set(pos, wat);
    }
    
    function unset(bytes12 pos) public {
        m.unset(pos);
    }

    function unset(address wat) public {
        m.unset(wat);
    }
}


contract Test is DSTest {
    Medianizer m;
    DSValue c1;
    DSValue c2;
    DSValue c3;
    DSValue c4;
    DSValue c5;

    function setUp() public {
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
    
    function testNoValues() public {
        m.poke();

        assertHasNoValue(m);
    }

    function testOneValue() public {
        m.set(c1);
        
        m.poke();

        assertHasValue(m, 5 ether);
    }

    function testTwoValues() public {
        m.set(c1);
        m.set(c2);
        
        m.poke();

        assertHasValue(m, 7.5 ether);
    }

    function testThreeValues() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        
        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testFourValues() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        m.set(c4);
        
        m.poke();

        assertHasValue(m, 7.5 ether);
    }

    function testFiveValues() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        m.set(c4);
        m.set(c5);
        
        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testRearrangeValues() public {
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

    function testFiveValuesDifferentOrder() public {
        m.set(c3);
        m.set(c2);
        m.set(c5);
        m.set(c4);
        m.set(c1);

        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testOneOfThreeVoid() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        c1.void();

        m.poke();

        assertHasValue(m, 8.5 ether);
    }

    function testTwoOfThreeVoid() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        c1.void();
        c2.void();

        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testAllThreeVoid() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        c1.void();
        c2.void();
        c3.void();

        m.poke();

        assertHasNoValue(m);
    }

    function testBelowMinimum() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.setMin(2);

        c1.void();
        c2.void();

        m.poke();

        assertHasNoValue(m);
    }

    function testEqualToMinimum() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.setMin(1);

        c1.void();
        c2.void();

        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testAboveMinimum() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.setMin(2);

        m.poke();

        assertHasValue(m, 7 ether);
    }

    function testRecursiveMedianizer() public {
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

    function testUnsetPos() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.unset(bytes12(2));

        m.poke();

        assertHasValue(m, 6 ether);
    }

    function testUnsetWat() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.unset(c2);

        m.poke();

        assertHasValue(m, 6 ether);
    }

    function testSetPos() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);

        m.set(2, c5);

        m.poke();

        assertHasValue(m, 5 ether);
    }

    function testSetPosAndSetAgain() public {
        m.set(c1);
        m.set(c2);
        m.set(c3);
        assertEq(m.indexes(c2), bytes12(2));

        m.set(2, c5);
        assertEq(m.indexes(c2), 0);

        m.set(c2);
        m.poke();
        assertHasValue(m, 6 ether);
    }

    function testNoValueWhenNoPoke() public {
        m.set(c1);

        assertHasNoValue(m);
    }

    function testDefaultMinimumIsOne() public {
        assertEq(uint(m.min()), uint(1));
    }

    function testFailSetPosZero() public {
        m.set(0, c1);
    }

    function testFailSetMinZero() public {
        m.setMin(0);
    }

    function testFailAddingDuplicated() public {
        m.set(c1);
        m.set(c1);
    }

    function testFailSet1Unauthorized() public {
        FakePerson p = new FakePerson(m);
        p.set(c1);
    }

    function testFailSet2Unauthorized() public {
        FakePerson p = new FakePerson(m);
        p.set(bytes12(1), c1);
    }

    function testFailUnset1Unauthorized() public {
        m.set(c1);
        FakePerson p = new FakePerson(m);
        p.unset(c1);
    }

    function testFailUnset2Unauthorized() public {
        m.set(c1);
        FakePerson p = new FakePerson(m);
        p.unset(bytes12(1));
    }

    // helper functions
    function assertHasNoValue(Medianizer med) internal constant {
        bool has;
        (, has) = med.peek();
        assert(!has);
    }
    function assertHasValue(Medianizer med, uint value) internal {
        bytes32 res; bool has;
        (res, has) = med.peek();
        assert(has);
        assertEqDecimal(uint256(res), value, 18);

        bytes32 resRead = med.read();
        assertEqDecimal(uint256(resRead), value, 18);
    }
}
