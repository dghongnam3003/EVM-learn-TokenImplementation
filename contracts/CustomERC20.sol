// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CustomERC20 {
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);
    event Paused(address account);
    event Unpaused(address account);

    // State variables
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(bytes32 => mapping(address => bool)) private _roles;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    bool private _paused;
    
    // Constants
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = bytes32(0);
    uint256 public constant MAX_SUPPLY = 2_000_000_000 * 10**18; // 2 billion tokens

    // Errors
    error NotAuthorized();
    error ContractPaused();
    error MaxSupplyExceeded();
    error InvalidAddress();
    error InsufficientBalance();
    error InsufficientAllowance();

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _roles[DEFAULT_ADMIN_ROLE][msg.sender] = true;
        emit RoleGranted(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Modifiers
    modifier onlyRole(bytes32 role) {
        if (!_roles[role][msg.sender]) revert NotAuthorized();
        _;
    }

    modifier whenNotPaused() {
        if (_paused) revert ContractPaused();
        _;
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    // Role management functions
    function grantRole(bytes32 role, address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _roles[role][account] = true;
        emit RoleGranted(role, account);
    }

    function revokeRole(bytes32 role, address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _roles[role][account] = false;
        emit RoleRevoked(role, account);
    }

    // Pause functions
    function pause() public onlyRole(PAUSER_ROLE) {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    // ERC20 standard functions
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public whenNotPaused returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public whenNotPaused returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public whenNotPaused returns (bool) {
        if (_allowances[from][msg.sender] < amount) revert InsufficientAllowance();
        _allowances[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    // Minting function
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) whenNotPaused {
        if (to == address(0)) revert InvalidAddress();
        if (_totalSupply + amount > MAX_SUPPLY) revert MaxSupplyExceeded();
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // Burning function
    function burn(uint256 amount) public whenNotPaused {
        if (_balances[msg.sender] < amount) revert InsufficientBalance();
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // Internal functions
    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0) || to == address(0)) revert InvalidAddress();
        if (_balances[from] < amount) revert InsufficientBalance();
        
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        if (owner == address(0) || spender == address(0)) revert InvalidAddress();
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}