// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.16;

import "dss-test/DssTest.sol";

import { Ngt } from "../Ngt.sol";
import { MkrNgt } from "../MkrNgt.sol";

contract Mkr is Ngt {}

contract MkrNgtTest is DssTest {
    Mkr     mkr;
    Ngt     ngt;
    MkrNgt  mkrNgt;

    function setUp() public {
        mkr = new Mkr();
        ngt = new Ngt();
        mkrNgt = new MkrNgt(address(mkr), address(ngt), 1200);
        mkr.mint(address(this), 1_000_000 * WAD);
        mkr.rely(address(mkrNgt));
        mkr.deny(address(this));
        ngt.rely(address(mkrNgt));
        ngt.deny(address(this));
    }

    function testExchange() public {
        assertEq(mkr.balanceOf(address(this)), 1_000_000 * WAD);
        assertEq(mkr.totalSupply(),            1_000_000 * WAD);
        assertEq(ngt.balanceOf(address(this)), 0);
        assertEq(ngt.totalSupply(),            0);

        mkr.approve(address(mkrNgt), 400_000 * WAD);
        mkrNgt.mkrToNgt(400_000 * WAD);
        assertEq(mkr.balanceOf(address(this)), 600_000 * WAD);
        assertEq(mkr.totalSupply(),            600_000 * WAD);
        assertEq(ngt.balanceOf(address(this)), 400_000 * WAD * 1200);
        assertEq(ngt.totalSupply(),            400_000 * WAD * 1200);

        ngt.approve(address(mkrNgt), 200_000 * WAD * 1200);
        mkrNgt.ngtToMkr(200_000 * WAD);
        assertEq(mkr.balanceOf(address(this)), 800_000 * WAD);
        assertEq(mkr.totalSupply(),            800_000 * WAD);
        assertEq(ngt.balanceOf(address(this)), 200_000 * WAD * 1200);
        assertEq(ngt.totalSupply(),            200_000 * WAD * 1200);
    }
}