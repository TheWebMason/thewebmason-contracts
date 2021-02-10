// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./Ownable.sol";


abstract contract Mintable is Ownable {
    mapping (address => bool) private _minters;

    event AddedMinter(address indexed minter);
    event RemovedMinter(address indexed minter);

    constructor () internal { }

    function addMinter(address account) public virtual onlyOwner {
        _minters[account] = true;
        emit AddedMinter(account);
    }

    function removeMinter(address account) public virtual onlyOwner {
        _minters[account] = false;
        delete _minters[account];
        emit RemovedMinter(account);
    }

    function isMinter(address account) public view virtual returns (bool) {
        return _minters[account];
    }

    modifier onlyMinter() {
        require(_minters[_msgSender()], "Mintable: caller is not the minter");
        _;
    }
}
