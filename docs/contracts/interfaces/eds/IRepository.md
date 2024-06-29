
# IRepository
## Description

The interface required for a repository.
This is a modified source from Aragon X, where interface names have been changed by generalising "plugin" in to source code address".
Implication of this is that this contract will not be aware of any setup code as opposed in original Aragon implementation which relied on having IPluginSetup requirements
To accomodate source code specific types, a new enum `SourceTypes` has been added. This enum is used to describe the means to consume the source code and OSx implementation can be seen as using "OSxPlugin" type.
Arguably, the enum could be moved into build metadata, if you have an opinion please reach out.

## Implementation

###  error VersionHashDoesNotExist

Thrown if a version does not exist.

```solidity
error VersionHashDoesNotExist(bytes32 versionHash) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `versionHash` | `bytes32` | The tag hash. |

###  error ReleaseZeroNotAllowed

Thrown if a release number is zero.

```solidity
error ReleaseZeroNotAllowed() 
```

###  error InvalidReleaseIncrement

Thrown if a release number is incremented by more than one.

```solidity
error InvalidReleaseIncrement(uint8 latestRelease, uint8 newRelease) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `latestRelease` | `uint8` | The latest release number. |
| `newRelease` | `uint8` | The new release number. |

###  error AlreadyInPreviousRelease

Thrown if the same contract exists already in a previous releases.

```solidity
error AlreadyInPreviousRelease(uint8 release, uint16 build, address source) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `release` | `uint8` | The release number of the already existing source. |
| `build` | `uint16` | The build number of the already existing source. |
| `source` | `address` | The  contract address. |

###  error EmptyReleaseMetadata

Thrown if the metadata URI is empty.

```solidity
error EmptyReleaseMetadata() 
```

###  error ReleaseDoesNotExist

Thrown if release does not exist.

```solidity
error ReleaseDoesNotExist() 
```

###  event VersionCreated

Emitted if the same source exists in previous releases.

```solidity
event VersionCreated(uint8 release, uint16 build, address source, bytes buildMetadata) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `release` | `uint8` | The release number. |
| `build` | `uint16` | The build number. |
| `source` | `address` | The address of the source code. |
| `buildMetadata` | `bytes` | The build metadata URI. |

###  event ReleaseMetadataUpdated

Emitted when a release's metadata was updated.

```solidity
event ReleaseMetadataUpdated(uint8 release, bytes releaseMetadata) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `release` | `uint8` | The release number. |
| `releaseMetadata` | `bytes` | The release metadata URI. |

### external function updateReleaseMetadata

Updates the metadata for release with content `@fromHex(releaseMetadata)`.

```solidity
function updateReleaseMetadata(uint8 release, bytes releaseMetadata) external 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `release` | `uint8` | The release number. |
| `releaseMetadata` | `bytes` | The release metadata URI. |

### external function createVersion

Creates a new version as the latest build for an existing release number or the first build for a new release number for the provided `source` contract address and metadata.

```solidity
function createVersion(uint8 release, address source, bytes buildMetadata, bytes releaseMetadata) external 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `release` | `uint8` | The release number. |
| `source` | `address` | The address of the source code. |
| `buildMetadata` | `bytes` | The build metadata URI. |
| `releaseMetadata` | `bytes` | The release metadata URI. |

### external function buildCount

Gets the total number of builds for a given release number.

```solidity
function buildCount(uint8 release) external view returns (uint256) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `release` | `uint8` | The release number. |
| **Output** | |
|  `0`  | `uint256` | The number of builds of this release. |

### external function getVersion

Returns the version for a tag hash.

```solidity
function getVersion(bytes32 tagHash) external view returns (struct Version) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `tagHash` | `bytes32` | The tag hash. |
| **Output** | |
|  `0`  | `struct Version` | The version associated with a tag hash. |

### external function getVersion

Returns the version associated with a tag.

```solidity
function getVersion(struct Tag tag) external view returns (struct Version) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `tag` | `struct Tag` | The version tag. |
| **Output** | |
|  `0`  | `struct Version` | The version associated with the tag. |

### external function getLatestVersion

Returns the latest version for a given source.

```solidity
function getLatestVersion(address source) external view returns (struct Version) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `source` | `address` | The source address |
| **Output** | |
|  `0`  | `struct Version` | The latest version associated with the source. |

### external function getLatestVersion

Returns the latest version for a given release number.

```solidity
function getLatestVersion(uint8 release) external view returns (struct Version) 
```

| Input | Type | Description |
|:----- | ---- | ----------- |
| `release` | `uint8` | The release number. |
| **Output** | |
|  `0`  | `struct Version` | The latest version of this release. |

### external function latestRelease

Returns the latest version for a given release number.

```solidity
function latestRelease() external view returns (uint8) 
```

| Output | Type | Description |
| ------ | ---- | ----------- |
|  `0`  | `uint8` | The latest version of this repository. |

<!--CONTRACT_END-->

# 
###  enum SourceTypes

```solidity
enum SourceTypes {
  Cloneable,
  Constructable,
  Distributable,
  OSxPlugin
}
```

# 
### public struct Tag

The struct describing the tag of a version obtained by a release and build number as `RELEASE.BUILD`.

| Input | Type | Description |
|:----- | ---- | ----------- |

*Releases mark incompatible changes (e.g., the plugin interface, storage layout, or incompatible behavior) whereas builds mark compatible changes (e.g., patches and compatible feature additions).*

```solidity
struct Tag {
  uint8 release;
  uint16 build;
}
```

# 
### public struct Version

The struct describing a version

| Input | Type | Description |
|:----- | ---- | ----------- |

```solidity
struct Version {
  struct Tag tag;
  address source;
  enum SourceTypes sourceType;
  bytes buildMetadata;
}
```

