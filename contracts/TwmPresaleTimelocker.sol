// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;


contract TwmPresaleTimelocker {
    string private _name = "TheWebMason Presale Timelocker";

    constructor () public {
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }
}
