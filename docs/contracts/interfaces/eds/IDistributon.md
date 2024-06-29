
# IDistributon
## Description

Interface for the Distributon contract.
The Distributon contract is responsible for serving package information on groups of source code from version controlled repositories.
NB: Distributed sources MUST implement IRepository

## Implementation

###  error InvalidVersion

```solidity
error InvalidVersion(address repository, struct VersionRequirement requirement) 
```

### external function getDistributionId

Retrieves the distribution ID.

```solidity
function getDistributionId() external view returns (bytes32) 
```

| Output | Type | Description |
| ------ | ---- | ----------- |
|  `0`  | `bytes32` | The distribution ID. |

*Distribution Id is calculated as keccak256(abi.encodePacked(requiredSources[].codeHash, initializerFnSelectors))*
### external function getDistribution

```solidity
function getDistribution() external view returns (struct Distribution) 
```

| Output | Type | Description |
| ------ | ---- | ----------- |
|  `0`  | `struct Distribution` | The distribution. |

*Retrieves the distribution.*
<!--CONTRACT_END-->

# 
###  enum VersionRequirementTypes

*Enum defining the types of version requirements for repositories.
- All: Matches any version.
- MajorVersion: Matches any version with the same major version number.
- ExactVersion: Matches the exact version specified.*

```solidity
enum VersionRequirementTypes {
  All,
  MajorVersion,
  ExactVersion
}
```

# 
### public struct VersionRequirement

| Input | Type | Description |
|:----- | ---- | ----------- |

*Struct defining a version requirement for a repository.*

```solidity
struct VersionRequirement {
  struct Tag baseVersion;
  enum VersionRequirementTypes requirementType;
}
```

# 
### public struct Distribution

| Input | Type | Description |
|:----- | ---- | ----------- |

*Struct defining a distribution of a repository.*

```solidity
struct Distribution {
  struct VersionRequirement[] requiredSources;
  bytes4[][] initializerFnSelectors;
}
```

