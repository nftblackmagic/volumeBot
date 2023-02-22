// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Flashloan.sol";
import "./interface/IWETH9.sol";

import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract FlashLoanTest is Test {
    WETH9 WETH = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    FlashLoanAAVE public flashLoan = new FlashLoanAAVE();
    function setUp() public {
        // vm.createSelectFork(vm.envString("MAINNET_RPC_URL"), 16_675_533); //fork mainnet at block 16675533
        vm.label(address(WETH), "WETH");
        vm.startPrank(<your wallet>);
        // vm.stopPrank();
    }

    function fromHexChar(uint8 c) public pure returns (uint8) {
        if (bytes1(c) >= bytes1('0') && bytes1(c) <= bytes1('9')) {
            return c - uint8(bytes1('0'));
        }
        if (bytes1(c) >= bytes1('a') && bytes1(c) <= bytes1('f')) {
            return 10 + c - uint8(bytes1('a'));
        }
        if (bytes1(c) >= bytes1('A') && bytes1(c) <= bytes1('F')) {
            return 10 + c - uint8(bytes1('A'));
        }
        revert("fail");
    }

    // Convert an hexadecimal string to raw bytes
    function fromHex(string memory s) public pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        require(ss.length%2 == 0); // length must be even
        bytes memory r = new bytes(ss.length/2);
        for (uint i=0; i<ss.length/2; ++i) {
            r[i] = bytes1(fromHexChar(uint8(ss[2*i])) * 16 +
                        fromHexChar(uint8(ss[2*i+1])));
        }
        return r;
    }

    function testFlashLoan() public {
        WETH.deposit{ value: 4 ether }(); // deposit 1 eth to weth
        WETH.transfer(address(flashLoan), 4 ether); // transfer 1 eth to flashloan contract
        console.log("Current weth balance %s",
          WETH.balanceOf(address(flashLoan))
        );
        WETH.approve(address(flashLoan), 10000 ether); // approve flashloan contract to spend weth

        // buy order
        string memory callData = '<the order from opensea>';
        bytes memory vara = fromHex(callData);

        // console.logBytes((vara));
        flashLoan.approvalWeth(address(WETH)); 
        flashLoan.executeFlashLoan(address(WETH), 100 ether, vara); //flashloan 1000 eth

        console.log("Current weth balance %s",
          WETH.balanceOf(address(flashLoan))
        );
    }

}
