// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ERC721Mock {
  string public name = 'Mock ERC721 Token';
  string public symbol = 'MERC721';
  uint256 public totalSupply;
  address public owner;

  mapping(address => uint256) public balances;
  mapping(uint256 => address) public owners;
  mapping(address => mapping(address => bool)) public operatorApprovals;
  mapping(uint256 => address) public tokenApprovals;

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, 'Only owner can mint');
    _;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function ownerOf(uint256 tokenId) public view returns (address) {
    address tokenOwner = owners[tokenId];
    require(tokenOwner != address(0), 'Token does not exist');
    return tokenOwner;
  }

  function mint(address to, uint256 tokenId) public onlyOwner {
    require(to != address(0), 'Cannot mint to zero address');
    require(owners[tokenId] == address(0), 'Token already minted');

    owners[tokenId] = to;
    balances[to] += 1;
    totalSupply += 1;

    emit Transfer(address(0), to, tokenId);
  }

  function transferFrom(address from, address to, uint256 tokenId) public {
    require(ownerOf(tokenId) == from, 'Not the owner of the token');
    require(to != address(0), 'Cannot transfer to zero address');

    require(
      msg.sender == from || getApproved(tokenId) == msg.sender || isApprovedForAll(from, msg.sender),
      'Not approved to transfer'
    );

    balances[from] -= 1;
    balances[to] += 1;
    owners[tokenId] = to;

    emit Transfer(from, to, tokenId);
  }

  function approve(address to, uint256 tokenId) public {
    address tokenOwner = ownerOf(tokenId);
    require(to != tokenOwner, 'Cannot approve current owner');
    require(msg.sender == tokenOwner || isApprovedForAll(tokenOwner, msg.sender), 'Not approved');

    tokenApprovals[tokenId] = to;
    emit Approval(tokenOwner, to, tokenId);
  }

  function getApproved(uint256 tokenId) public view returns (address) {
    return tokenApprovals[tokenId];
  }

  function setApprovalForAll(address operator, bool approved) public {
    operatorApprovals[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function isApprovedForAll(address _owner, address operator) public view returns (bool) {
    return operatorApprovals[_owner][operator];
  }

  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}
