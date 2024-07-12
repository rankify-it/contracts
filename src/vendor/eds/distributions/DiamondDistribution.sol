// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../abstracts/CloneDistributor.sol";
import "../../diamond/DiamondClonable.sol";
import "../../diamond/facets/DiamondCutFacet.sol";

contract DiamondDistribution is CloneDistributor {
    address immutable _reference;

    constructor(address owner) {
        address diamondCutFacet = address(new DiamondCutFacet());
        // Deploy the diamond proxy contract
        address diamondProxy = address(new DiamondClonable(owner, diamondCutFacet));
        _reference = diamondProxy;
    }

    function sources() internal view virtual override returns (address[] memory) {
        address[] memory _sources = new address[](1);
        _sources[0] = _reference;
        return _sources;
    }

    function getMetadata() public pure virtual override returns (string memory) {
        return "Diamond Distributor"; //ToDo: Add IPFS link with readme!
    }
}