
# IInstantiator
## Description

The Instantiator contract is responsible for instantiating new instances from SourceController

This interface is intended to use ISourceController as a source of authority for instantiating new instances
While this acts as registry of active instances, SourceController is registry of required versions
Hence in order to ensure proper authorization for target
Each time an instance is calling a target, `instanceCheck` should be called.
Implementation of `instanceCheck` should verify version requirements with SourceController
WARNING: Repository ources MUST contain IDistribution compliant sources

## Implementation

###  error InvalidVersion

```solidity
error InvalidVersion(address instance, struct Tag has, struct Tag needs) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instance` | `address` | The address of the instance. |
| `has` | `struct Tag` | The current version tag of the instance. |
| `needs` | `struct Tag` | The required version tag for the instance. |

*Error thrown when an instance has an invalid version.*
###  error InvalidRepository

```solidity
error InvalidRepository(address repository) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repository` | `address` | The address of the repository. |

*Error thrown when an invalid repository is provided.*
###  error NotAnInstance

```solidity
error NotAnInstance(address instance) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instance` | `address` | The address to check. |

*Error thrown when an address is not an instance.*
###  event Instantiated

```solidity
event Instantiated(uint256 instanceId, contract IRepository repository, struct Tag version, bytes[][] args) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instanceId` | `uint256` | id of the new instance. |
| `repository` | `contract IRepository` | The address of the repository used for instantiation. |
| `version` | `struct Tag` | The version tag of the new instance. |
| `args` | `bytes[][]` | The arguments used for instantiation. |

*Emitted when a new instance is successfully instantiated.*
###  event Removed

```solidity
event Removed(address instance) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instance` | `address` | The address of the removed instance. |

*Emitted when an instance is removed.*
### external function instantiate

```solidity
function instantiate(contract IRepository repository, bytes[][] args) external returns (uint256 instanceId) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repository` | `contract IRepository` | The repository used for instantiation. |
| `args` | `bytes[][]` | The arguments used for instantiation. |
| **Output** | |
|  `instanceId`  | `uint256` | of the newly instantiated instance. |

*Instantiates a new contract instance using the provided repository and arguments.
NB for "constructable" source types, the first argument should be constructor code.*
### external function instantiateExact

```solidity
function instantiateExact(contract IRepository repository, struct Tag version, bytes[][] args) external returns (uint256 instanceId) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repository` | `contract IRepository` | The repository used for instantiation. |
| `version` | `struct Tag` | The version tag required for instantiation. |
| `args` | `bytes[][]` | The arguments used for instantiation. |
| **Output** | |
|  `instanceId`  | `uint256` | of the newly instantiated instance. |

*Instantiates a new contract instance using the provided repository, version, and arguments.*
### external function tryInstanceId

```solidity
function tryInstanceId(address instance) external view returns (uint256) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instance` | `address` | The address to check. |
| **Output** | |
|  `0`  | `uint256` | if the address is a valid instance, the instance id is returned, otherwise 0. |

*Checks if the provided address is a valid instance.*
### external function instanceCheck

```solidity
function instanceCheck(address instance) external view returns (bool) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instance` | `address` | The address to check. |
| **Output** | |
|  `0`  | `bool` | True if the address is a valid instance and passes the instance check, false otherwise. |

*Checks if the provided address is a valid instance and passes both instance requirements and SourceController refquirements.*
### external function instanceVersion

```solidity
function instanceVersion(address instance) external view returns (struct Tag version) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instance` | `address` | The address of the instance. |
| **Output** | |
|  `version`  | `struct Tag` | The version tag of the instance. |

*Retrieves the version tag of the provided instance.*
### external function remove

```solidity
function remove(address instance) external 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instance` | `address` | The address of the instance to remove. |

*Removes an instance from the system.*
### external function getSourceControl

```solidity
function getSourceControl(address instance) external view returns (contract ISourceController) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instance` | `address` | The address of the instance. |
| **Output** | |
|  `0`  | `contract ISourceController` | ISourceController The source control contract associated with the instance. |

*Retrieves the source control contract associated with the provided instance.*
### external function getInstance

```solidity
function getInstance(uint256 instanceId) external view returns (address[] instaneContracts) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `instanceId` | `uint256` | The id of the instance. |
| **Output** | |
|  `instaneContracts`  | `address[]` | associated with the instance id. |

*Retrieves the instance contracts associated with the provided instance id.*
### external function getInstancesNum

```solidity
function getInstancesNum() external view returns (uint256) 
```

| Output | Type | Description |
| ------ | ---- | ----------- |
|  `0`  | `uint256` | The number of instances in the system. |

*Retrieves the number of instances in the system.*
### external function getActiveInstancesIds

```solidity
function getActiveInstancesIds() external view returns (uint256[]) 
```

| Output | Type | Description |
| ------ | ---- | ----------- |
|  `0`  | `uint256[]` | list of active instance ids |

*Retrieves the instance id associated with the provided instance address.*
<!--CONTRACT_END-->

