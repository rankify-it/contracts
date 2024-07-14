// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IDistributor.sol";
import "../interfaces/IDistribution.sol";
import "../abstracts/CodeIndexer.sol";
import "../interfaces/IInitializer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../abstracts/Distributor.sol";
contract RankifyInstanceDistributor is Distributor, Ownable {

    constructor (address _owner) Ownable(_owner) {

    }

    function instantiate(bytes32 id, bytes calldata args) public returns (address[] memory)
    {
        return super._instantiate(id, args);
    }

    function addDistribution(bytes32 id, bytes32 initId) onlyOwner public {
        super._addDistribution(id, initId);
    }

    function removeDistribution(bytes32 id) onlyOwner public {
        super._removeDistribution(id);
    }


}