// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./errors/MatrixErrors.sol";

contract GetNftReward is Ownable {

    IERC20 public USDB ;
    address public Matrix3D;
    constructor(address _matrixContract,address _usdb) Ownable(_matrixContract) {
        Matrix3D = _matrixContract;
        USDB= IERC20(_usdb);
    }
    modifier OnlyMatrixGame(address _matrix3D) {
        if (Matrix3D != _matrix3D)
            revert MatrixErrors.Matrix3DErrors(
                MatrixErrors.Errors.AccessDenied
            );

        _;
    }
    struct UserData {
        address user;
        uint256 nftCount;
    }
    struct RoundInfo {
        uint256 reward;
        uint256 totalNfts;
    }
    RoundInfo public gameData;
    mapping(address user => UserData) public userData;
    function updateState(uint reward, uint32 nftCount, address user) public OnlyMatrixGame(msg.sender) {
        USDB.transferFrom(msg.sender, address(this), reward);
        gameData.reward += reward;
        gameData.totalNfts += nftCount;
        userData[user].nftCount += nftCount;
        userData[user].user = user;
    }
    
    function getReward(address user) public OnlyMatrixGame(msg.sender)  {
        uint count = userData[user].nftCount;
        userData[user].nftCount = 0;
        uint totalNfts = gameData.totalNfts;
        gameData.totalNfts -= count;
        uint reward = gameData.reward;
        uint userReward = (count * reward) / totalNfts;
        uint totalYield = USDB.balanceOf(address(this)) - reward;
        reward -= userReward;
        uint yieldReward = (count * totalYield) / totalNfts;
        uint gasReward = (count * address(this).balance) / totalNfts;
        (bool success, ) = user.call{value: gasReward}("");
        
        

        require(success, "Ether transfer failed");
        USDB.transfer(user, yieldReward + userReward);
    }
    
}

