// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./Mintable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

interface ITwm {
    function approve(address spender, uint256 amount) external returns (bool);
    function mint(address recipient, uint256 amount) external returns (bool);
}

interface ITwmPresaleTimelocker {
    function add(address beneficiary, uint256 amount) external returns (bool);
}


contract TwmPre is Mintable, IERC20 {
    using SafeMath for uint256;

    mapping (address => bool) private _minters;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "TheWebMason Presale Token";
    string private _symbol = "TWM-PRE";
    uint8 private _decimals = 18;

    uint256 private _totalSupply;
    uint256 private _cap = 250_000_000e18;

    bool private _stopped;
    address private _token;
    address private _timelocker;

    constructor () public {
        addMinter(_msgSender());
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function token() public view virtual returns (address) {
        return _token;
    }

    function timelocker() public view virtual returns (address) {
        return _timelocker;
    }

    function stop(address token_, address timelocker_) public virtual onlyOwner {
        require(_stopped == false, "TwmPresale: already stopped");
        require(token_ != address(0), "TwmPresale: token is the zero address");
        require(timelocker_ != address(0), "TwmPresale: timelocker is the zero address");
        _stopped = true;
        _token = token_;
        _timelocker = timelocker_;
    }

    function stopped() public view virtual returns (bool) {
        return _stopped;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function swapToTWM() public virtual {
        address msgSender = _msgSender();
        uint256 amount = _balances[msgSender];
        require(_stopped == true, "TwmPresale: too early");
        require(amount > 0, "TwmPresale: insufficient funds");

        ITwm(_token).mint(address(this), amount);
        ITwm(_token).approve(_timelocker, amount);
        ITwmPresaleTimelocker(_timelocker).add(msgSender, amount);
        _burn(msgSender, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "TwmPresale: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "TwmPresale: decreased allowance below zero"));
        return true;
    }

    function mint(address account, uint256 amount) public virtual onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }

    function burn(uint256 amount) public virtual returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function burnFrom(address account, uint256 amount) public virtual returns (bool) {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "TwmPresale: burn amount exceeds allowance");
        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "TwmPresale: transfer from the zero address");
        require(recipient != address(0), "TwmPresale: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "TwmPresale: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "TwmPresale: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "TwmPresale: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(amount, "TwmPresale: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "TwmPresale: approve from the zero address");
        require(spender != address(0), "TwmPresale: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
        if (from == address(0)) {
            require(_stopped == false, "TwmPresale: presale stopped");
            require(totalSupply().add(amount) <= cap(), "TwmPresale: cap exceeded");
        }
    }
}
