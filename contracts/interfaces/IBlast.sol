// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
interface IBlast {
    function claimAllGas(
        address contractAddress,
        address recipient
    ) external returns (uint256);
    function configureClaimableGas() external;
    function configureGovernor(address governor) external;
}
