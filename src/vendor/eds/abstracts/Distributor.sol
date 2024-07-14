// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "../interfaces/IDistribution.sol";
import "../interfaces/IDistributor.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../interfaces/IInitializer.sol";
import "../abstracts/CodeIndexer.sol";
abstract contract Distributor is IDistributor, CodeIndexer {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    EnumerableSet.Bytes32Set private distirbutionsSet;
    mapping(bytes32 => IInitializer) private initializers;
    mapping(address => bytes32) private instancesDistribution;


    function getDistributions() public view returns (bytes32[] memory) {
        return distirbutionsSet.values();
    }

    function getDistributionURI(bytes32 id) public view returns (string memory) {
        ICodeIndex codeIndex = getContractsIndex();
        return IDistribution(codeIndex.get(id)).getMetadata();
    }

    function _addDistribution(bytes32 id, bytes32 initId) internal virtual {
        ICodeIndex codeIndex = getContractsIndex();
        if (codeIndex.get(id) == address(0)) revert DistributionNotFound(id);
        if (codeIndex.get(initId) == address(0) && initId != bytes32(0))
            revert InitializerNotFound(initId);
        if (distirbutionsSet.contains(id)) revert DistributionExists(id);
        distirbutionsSet.add(id);
        initializers[id] = IInitializer(codeIndex.get(id));
        emit DistributionAdded(id, initId);
    }

    function _removeDistribution(bytes32 id) internal virtual {
        if (!distirbutionsSet.contains(id)) revert DistributionNotFound(id);
        distirbutionsSet.remove(id);
        emit DistributionRemoved(id);
    }

    function _instantiate(bytes32 id, bytes calldata args) internal virtual returns (address[] memory instances) {
         ICodeIndex codeIndex = getContractsIndex();
        if (!distirbutionsSet.contains(id)) revert DistributionNotFound(id);
        instances = IDistribution(codeIndex.get(id)).instantiate();
        bytes4 selector = IInitializer.initialize.selector;
        // This ensures instance owner (distributor) performs initialization.
        // It is distirbutor responsibility to make sure calldata and initializer are safe to execute
        (bool success, bytes memory result) = address(initializers[id]).delegatecall(
            abi.encodeWithSelector(selector, args)
        );
        require(success, string(result));
        emit DistributedAndInitialized(id, args);
        return instances;
    }

     function beforeCallValidation(
        bytes memory layerConfig,
        bytes4 selector,
        address sender,
        uint256 value,
        bytes memory data
    ) public view returns (bytes memory) {
        bytes32 id = instancesDistribution[sender];
        if(id != bytes32(0) && distirbutionsSet.contains(id) == true)
        {
            return "";
        }
        else
        {
             revert InvalidInstance(sender);
        }
    }

    function afterCallValidation(
        bytes memory layerConfig,
        bytes4 selector,
        address sender,
        uint256 value,
        bytes memory data,
        bytes memory beforeCallResult
    ) public {
    }

}
