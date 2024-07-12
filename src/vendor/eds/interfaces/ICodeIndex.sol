// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICodeIndex {
    event Indexed(address indexed container, bytes32 indexed codeHash);
    error alreadyExists(bytes32 id, address referance);

    function register(address container) external;

    function get(bytes32 id) external view returns (address);
}
