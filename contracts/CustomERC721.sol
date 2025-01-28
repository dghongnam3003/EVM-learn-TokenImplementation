// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CustomERC721 {
    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // State variables
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    
    // Constants
    uint256 public constant MAX_SUPPLY = 100_000; // max can be minted
    string public constant BASE_URI = "https://metadata.example/";

    // Mappings
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Errors
    error NonexistentToken();
    error InvalidReceiver();
    error NotOwnerOrApproved();
    error MaxSupplyExceeded();
    error InvalidTokenId();
    error NotTokenOwner();

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // Modifiers
    modifier onlyTokenOwner(uint256 tokenId) {
        if (_owners[tokenId] != msg.sender) revert NotTokenOwner();
        _;
    }

    // View functions
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Invalid address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) revert NonexistentToken();
        return owner;
    }

    // Token URI
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        if (_owners[tokenId] == address(0)) revert NonexistentToken();
        return string(abi.encodePacked(BASE_URI, _toString(tokenId)));
    }

    // Minting function - Free for all
    function mint() public returns (uint256) {
        if (_totalSupply >= MAX_SUPPLY) revert MaxSupplyExceeded();
        
        uint256 tokenId = _totalSupply + 1;
        _mint(msg.sender, tokenId);
        return tokenId;
    }

    // Approval functions
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "Not authorized"
        );
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        if (_owners[tokenId] == address(0)) revert NonexistentToken();
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // Transfer functions
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not authorized"
        );
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not authorized"
        );
        _safeTransfer(from, to, tokenId, data);
    }

    // Internal functions
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) revert InvalidReceiver();
        if (_owners[tokenId] != address(0)) revert("Token already exists");

        _totalSupply++;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        if (ownerOf(tokenId) != from) revert NotTokenOwner();
        if (to == address(0)) revert InvalidReceiver();

        _beforeTokenTransfer(from, to, tokenId);

        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;
        delete _tokenApprovals[tokenId];

        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "Transfer to non-ERC721Receiver"
        );
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (
            spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender
        );
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}

    // Utility functions
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length == 0) {
            return true;
        }

        try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
            return retval == IERC721Receiver.onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("Transfer to non-ERC721Receiver");
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}