// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {GatekeeperOne} from "../src/GatekeeperOne.sol";

// This is what we have done for the solution
// For the first modifier, we need to make sure that the sender is not the transaction originator, so
// As from previous exercises we where able to go call the function from a middle man contact and create a scenario
// where the sender is not the transaction originator

// For the second modifier, we needed to solve the third one a create a brute force method where we call the function using the
// Low level call and pass the parameters to be, create a for loop where i is the gas being added, until the result is true we break from the function
// Meaning its passed and for the chain execeution we already know what i is

// For the third modifier, the parameter is bytes8 so 0xb1b2b3b4b5b6b7b8
// bytes8 is similar to uint64 in terms of size however change when we cast down. In uints we cast down and leave the least signuficant bits
// In bytes8 we cast down and leave the most significant bits
// By casting down we needed to make sure 0xb5b6b7b8 == 0x00b7b8 so we know that b5b6 are 0 0

// In comparizon cases we compare upwords so, uint16 is then changed to uint32 stricly for comparzon

// Next we needed to make sure that 0xb1b2b3b4b5b6b7b8 is not equal to 0x0000b5b6b7b8
// We need to choose one byte from the first 4 and use byte casting to get the value so in this case it is 0xFF0000000000FFFF (THis is in nibbles)

// Finally we needed to make sure that the keywe choose when casted to uint32 0xb5b6b7b8 is equal to the transaction originator in unit16 so
// 0xb7b8 should be 0xc50b (This is in nibbles)

contract GatekeeperOpener {
    GatekeeperOne public gatekeeper =
        GatekeeperOne(0xc4A0cdd2ccC56696952014AE86251168F7311111);

    function enter() public {
        // for (uint256 i = 0; i < 120; i++) {
        //     console.log(i);
        (bool result, ) = address(gatekeeper).call{gas: 106 + 150 + 8191 * 3}(
            abi.encodeWithSignature(
                "enter(bytes8)",
                bytes8(uint64(uint160(tx.origin))) & 0xFF0000000000FFFF
            )
        );

        // if (result) {
        //     break;
        // }
        // }
    }
}

contract GatekeeperOneScript is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        GatekeeperOpener opener = new GatekeeperOpener();
        opener.enter();
        vm.stopBroadcast();
    }
}
