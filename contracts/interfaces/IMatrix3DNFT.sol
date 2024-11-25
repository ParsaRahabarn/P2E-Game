// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

interface IMatrix3DNFT is IERC1155MetadataURI {
    function Matrix3D() external view returns (address);
    function BluePillMetadata() external view returns (string memory);
    function RedPillMetadata() external view returns (string memory);
    function mint(address _user, uint token_id, uint32 _count) external;
}
