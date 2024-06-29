
# IVSourceController
## Description

Interface for the Source Controller contract.

## Implementation

###  event RepositoryAdded

```solidity
event RepositoryAdded(contract IRepository repository, struct VersionRequirement versionRequired) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repository` | `contract IRepository` | The address of the repository. |
| `versionRequired` | `struct VersionRequirement` | The version requirement for the repository. |

*Emitted when a repository is added to the Source Controller.*
###  event VersionRequirementSet

```solidity
event VersionRequirementSet(contract IRepository repository, struct VersionRequirement versionRequired) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repository` | `contract IRepository` | The address of the repository. |
| `versionRequired` | `struct VersionRequirement` | The new version requirement for the repository. |

*Emitted when the version requirement is set for a repository.*
### external function getDistributors

```solidity
function getDistributors() external view returns (address[]) 
```

| Output | Type | Description |
| ------ | ---- | ----------- |
|  `0`  | `address[]` | An array of distributor addresses. |

*Returns an array of distributors.*
### external function isDistributor

```solidity
function isDistributor(address distributor) external view returns (bool) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `distributor` | `address` | The address to check. |
| **Output** | |
|  `0`  | `bool` | A boolean indicating whether the address is a distributor. |

*Checks if an address is a distributor.*
### external function setVersionRequirement

```solidity
function setVersionRequirement(contract IRepository repository, struct VersionRequirement versionRequired) external 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repository` | `contract IRepository` | The address of the repository. |
| `versionRequired` | `struct VersionRequirement` | The version requirement for the repository. |

*Sets the version requirement for a repository.*
### external function getVersionRequired

```solidity
function getVersionRequired(contract IRepository repository) external view returns (struct VersionRequirement) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repository` | `contract IRepository` | The address of the repository. |
| **Output** | |
|  `0`  | `struct VersionRequirement` | The version requirement for the repository. |

*Gets the version requirement for a repository.*
### external function addDistributor

```solidity
function addDistributor(contract IRepository repository, struct VersionRequirement versionRequired) external 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repository` | `contract IRepository` | The address of the repository. |
| `versionRequired` | `struct VersionRequirement` | The version requirement for the repository. |

*Adds a distributor for a repository.*
### external function removeDistributor

```solidity
function removeDistributor(contract IRepository repository) external 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repository` | `contract IRepository` | The address of the repository. |

*Removes a distributor for a repository.*
### external function addBatchDistributors

```solidity
function addBatchDistributors(contract IRepository[] repositories, struct VersionRequirement[] requirements) external 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repositories` | `contract IRepository[]` | An array of repository addresses. |
| `requirements` | `struct VersionRequirement[]` | An array of version requirements for the repositories. |

*Adds multiple distributors for multiple repositories.*
### external function removeBatchDistributors

```solidity
function removeBatchDistributors(contract IRepository[] repositories) external 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repositories` | `contract IRepository[]` | An array of repository addresses. |

*Removes multiple distributors for multiple repositories.*
### external function setBatchVersionRequirements

```solidity
function setBatchVersionRequirements(contract IRepository[] repositories, struct VersionRequirement[] requirements) external 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `repositories` | `contract IRepository[]` | An array of repository addresses. |
| `requirements` | `struct VersionRequirement[]` | An array of version requirements for the repositories. |

*Sets multiple version requirements for multiple repositories.*
<!--CONTRACT_END-->

