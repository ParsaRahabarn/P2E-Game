// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGetNftReward {
    struct UserData {
        address user;
        uint256 nftCount;
    }

    struct RoundInfo {
        uint256 reward;
        uint256 totalNfts;
    }

    function updateState(
        uint256 reward,
        uint32 nftCount,
        address user
    ) external;
    function getReward(address user) external;

    function USDB() external view returns (address);
    function gameData() external view returns (RoundInfo memory);
    function userData(address _user) external view returns (UserData memory);
}
