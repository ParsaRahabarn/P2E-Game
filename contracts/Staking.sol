// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./errors/MatrixErrors.sol";
contract MatrixStaking is Ownable {
    bool initialized;
    IERC20 public MatrixToken;
    IERC20 public USDB;
    address public Matrix3D;

    uint64 public stakePositionId;
    StakeDetails public stakeDetails;
    mapping(address => uint64[]) public stakePostionIds;
    mapping(uint64 => UserStake) public userStake;
    constructor() Ownable(msg.sender) {
        stakeDetails.startStakeTime = block.timestamp;
    }
    function initialize(address _matrix3D,address _matrixToken,address _usdb)external onlyOwner(){
        if (initialized) {
            revert MatrixErrors.Matrix3DErrors(
                MatrixErrors.Errors.AlreadyInitialized
            );
        }
        initialized=true;
        Matrix3D=_matrix3D;
        MatrixToken = IERC20(_matrixToken);
        USDB = IERC20(_usdb);
        
        stakeDetails.startStakeTime = block.timestamp;
    }

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
    modifier checkReward(uint64 id) {
        if (userStake[id].received) {
            revert MatrixErrors.Matrix3DErrors(
                MatrixErrors.Errors.RewardAlreadyReceivd
            );
        }
        _;
    }
    modifier OnlyMatrixGame(address _matrix3D) {
        if (Matrix3D != _matrix3D)
            revert MatrixErrors.Matrix3DErrors(
                MatrixErrors.Errors.AccessDenied
            );

        _;
    }
    
    function endStake() public OnlyMatrixGame(msg.sender) {
        stakeDetails.endStakeTime = block.timestamp;
    }
    function stake(address user,uint amount) public OnlyMatrixGame(msg.sender) {
        MatrixToken.transferFrom(msg.sender, address(this), amount);
        UserStake memory _userStake = UserStake(
            user,
            amount,
            timestamp(),
            stakePositionId,
            false
        );
        userStake[stakePositionId] = _userStake;
        stakePostionIds[user].push(stakePositionId);
        stakePositionId++;
        stakeDetails.amountStaked += amount;
    }
    function addReward(uint reward) public OnlyMatrixGame(msg.sender){
        USDB.transferFrom(msg.sender, address(this), reward);
        stakeDetails.reward += reward;
    }
    function showRewardPercent(uint64 _id) public view returns (uint) {
        uint termSpendTime = timestamp() - stakeDetails.startStakeTime;
        uint userSpendTime = (timestamp() - userStake[_id].startStakeTime) *
            1e2;
        uint userShare = userStake[_id].amountStaked * 1e6;
        uint totalShare = stakeDetails.amountStaked;
        uint rewardPercent = ((userSpendTime / termSpendTime) * userShare) /
            totalShare;

        return rewardPercent;
    }

    function unstake(uint32 _id) public OnlyMatrixGame(msg.sender) checkReward(_id) {
        userStake[_id].received = true;
        uint stakedAmount = userStake[_id].amountStaked;
        MatrixToken.transfer(userStake[_id].user, stakedAmount);
        uint totalReward = stakeDetails.reward;
        uint rewardPercent = showRewardPercent(_id);
        uint yieldAmount = USDB.balanceOf(address(this)) - totalReward;
        uint holderReward = (rewardPercent * totalReward) / 1e8;
        uint yieldReward = (rewardPercent * yieldAmount) / 1e8;
        USDB.transfer(userStake[_id].user, holderReward + yieldReward);
    }

    function userPositions() public view returns (uint64[] memory) {
        return stakePostionIds[msg.sender];
    }
    function getUserPositions() public view returns (UserStake[] memory) {
        uint64 count = uint64(stakePostionIds[msg.sender].length);
        UserStake[] memory data = new UserStake[](count);

        for (uint64 i = 0; i < count; i++) {
            uint64 id = stakePostionIds[msg.sender][i];
            data[i] = userStake[id];
        }

        return data;
    }
    function timestamp() public view returns (uint) {
        if (stakeDetails.endStakeTime == 0) {
            return block.timestamp;
        } else return stakeDetails.endStakeTime;
    }
}

