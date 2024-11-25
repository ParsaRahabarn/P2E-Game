// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMatrixStaking {
    struct StakeDetails {
        uint reward;
        uint amountStaked;
        uint startStakeTime;
        uint endStakeTime;
    }

    struct UserStake {
        address user;
        uint amountStaked;
        uint startStakeTime;
        uint64 positionId;
        bool received;
    }

    function endStake() external;
    function stake(address user,uint amount) external;
    function addReward(uint reward) external;
    function showRewardPercent(uint64 _id) external view returns (uint);
    function unstake(uint32 _id) external;
    function userPositions() external view returns (uint64[] memory);
    function getUserPositions() external view returns (UserStake[] memory);
    function timestamp() external view returns (uint);
    function initialize(address matrixGame,address _matrixToken,address _usdb)external;
}
