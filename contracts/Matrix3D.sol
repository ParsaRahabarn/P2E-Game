// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./errors/MatrixErrors.sol";
import "./interfaces/IMatrix3DNFT.sol";
import "./interfaces/IBlast.sol";
import "./interfaces/IBlast.sol";
import "./interfaces/IGetNftReward.sol";
import "./interfaces/IMatrixStaking.sol";
import "hardhat/console.sol";

contract Matrix3D is Ownable , ReentrancyGuard{
    // ? --------------- VARIABLES ---------------- ? //
    uint24 public immutable day;
    IERC20 public immutable USDB;
    address public immutable MatrixToken;
    IBlast public immutable BLAST;
    IMatrix3DNFT public PillNftContract;
    uint256 public teamReward;
    uint256 public startPrice;
    address public teamWallet;
    address public deusExMachina;
    address public templateStakingContract;
    mapping(uint32 => address) StakingContracts;
    IMatrixStaking public StakingContract;
    IGetNftReward public pillNftRewardContract;
    uint32 public gameId;
    uint8[4] public increasedTime;
    uint128[4] public amountsRanges;
    uint256[3] public topThreeNFTs;
    address[3] public topThreeUsers;
    
    mapping(uint32 gameId => RoundInfo) public roundInfo;
    
    mapping(uint32 gameId => address winner) public lastBuyer;
    mapping(uint32 gameId => mapping(address userAddress => Buyers))
        public buyersInfo;

    // ? --------------- MODIFIERS ---------------- ? //

    modifier checkRoundEnded(uint32 _gameId) {
        if (block.timestamp > roundInfo[_gameId].endTime) {
            revert MatrixErrors.Matrix3DErrors(
                MatrixErrors.Errors.RoundNotEnded
            );
        }
        _;
    }
    // ? --------------- STRUCTS ---------------- ? //

    struct Buyers {
        address nftOwner;
        uint32 redPillCount;
        uint32 bluePillCount;
        bool rewardReceivd;
    }
    struct RoundInfo {
        uint256 startTime;
        uint256 endTime;
        address winner;
        uint256 totalSupply;
        uint256 winningAmount;
        bool rewardReceivd;
        bool ended;
        uint32 gameId;
        uint32 totalRedPillBuyed;
        uint32 totalBluePillBuyed;
    }
    enum Pill {
        RedPill,
        BluePill
    }

    // ? --------------- CONSTRUCTORS ---------------- ? //

    constructor(
        address _teamWallet,
        address _deusExMachina,
        address _templateStakingContract,
        address _pillNftContract,
        address _matrixToken,
        address _usdb
    ) Ownable(msg.sender) {
        amountsRanges = [100_000e18, 1_000_000e18, 5_000_000e18, 10_000_000e18];
        increasedTime = [30, 15, 7, 5];
        startPrice = 100_000e18;
        templateStakingContract = _templateStakingContract;
        deusExMachina = _deusExMachina;
        teamWallet = _teamWallet;
        USDB = IERC20(_usdb);
        BLAST = IBlast(0x4300000000000000000000000000000000000002);
        PillNftContract = IMatrix3DNFT(_pillNftContract);
        address cloneAddress = Clones.clone(templateStakingContract);
        StakingContracts[gameId] = cloneAddress;
        StakingContract = IMatrixStaking(cloneAddress);
        MatrixToken=_matrixToken;
        StakingContract.initialize(address(this),MatrixToken,_usdb);
        // ! remove
        day = 600;
        //! TODO
        // day = 86400;
        
        // BLAST.configureClaimableGas();
    }

    // ? --------------- STARTING POINT ---------------- ? //
    function startNewGame()onlyOwner() external {
        if (
            block.timestamp > roundInfo[gameId].endTime &&
            roundInfo[gameId].endTime != 0
        ) {
            //! remove  
            uint startTime = block.timestamp;
            //! TODO
            // uint startTime = roundInfo[gameId].endTime + (day * 7);
            uint endTime = startTime+day;
            uint totalSupply = roundInfo[gameId].totalSupply;
            teamReward += totalSupply / 10;
            uint nextRound = totalSupply / 10;
            uint topThreeReward=USDB.balanceOf(address(this))-totalSupply;
            if (topThreeUsers[0]!=address(0)) 
            USDB.transfer(topThreeUsers[0],topThreeReward/3);
            topThreeUsers[0]=address(0);
            if (topThreeUsers[1]!=address(0)) 
            USDB.transfer(topThreeUsers[1],topThreeReward/3);
            topThreeUsers[1]=address(0);
            if (topThreeUsers[2]!=address(0)) 

            USDB.transfer(topThreeUsers[2],topThreeReward/3);
            topThreeUsers[2]=address(0);
            topThreeNFTs[0]=0;
            topThreeNFTs[1]=0;
            topThreeNFTs[2]=0;
            uint winningAmount = totalSupply - (teamReward + nextRound);
            roundInfo[gameId].ended = true;
            roundInfo[gameId].winner = lastBuyer[gameId];
            roundInfo[gameId].winningAmount = winningAmount;
            address cloneAddress = Clones.clone(templateStakingContract);
            StakingContracts[gameId] = cloneAddress;
            StakingContract = IMatrixStaking(cloneAddress);
            StakingContract.initialize(address(this),MatrixToken,address(USDB));
            gameId++;
            RoundInfo memory round = RoundInfo(
                startTime,
                endTime,
                address(0),
                nextRound,
                0,
                false,
                false,
                gameId,
                0,
                0
            );

            roundInfo[gameId] = round;
    }
    }

    function initializeGame(address _pillNftRewardContract,uint amount) external onlyOwner() {
        pillNftRewardContract = IGetNftReward(_pillNftRewardContract);
        if (roundInfo[gameId].endTime != 0) {
            revert MatrixErrors.Matrix3DErrors(
                MatrixErrors.Errors.AlreadyInitialized
            );
        }
        // USDB.transferFrom(msg.sender, address(this), startPrice);
        USDB.transferFrom(msg.sender, address(this), amount);
        uint64 endTime = uint64(block.timestamp + day);
        RoundInfo memory round = RoundInfo(
            uint64(block.timestamp),
            endTime,
            address(0),
            amount,
            0,
            false,
            false,
            gameId,
            0,
            0
        );
        roundInfo[gameId] = round;
    }

    // ? --------------- SEND FUNCTIONS ---------------- ? //

    function buyPill(
        Pill _pill,
        uint32 _count,
        address _referrer
    ) external nonReentrant {
        uint amount = _count * pillPrice();
        USDB.transferFrom(msg.sender, address(this), amount);

        if (_referrer != address(0)) {
            uint reffererReward = amount / 10;
            USDB.transfer(_referrer, reffererReward);
            amount -= reffererReward;
        }
        Buyers memory buyer = pay(msg.sender, amount, _pill, _count);
        lastBuyer[gameId] = msg.sender;
        if (buyer.nftOwner == address(0)) {
            buyer.nftOwner = msg.sender;
        }
        PillNftContract.mint(
            msg.sender,
            gameId * 10 + uint32(_pill),
            uint32(_count)
        );

        if (
            roundInfo[gameId].endTime + increaseTimeBy() - block.timestamp > day
        ) roundInfo[gameId].endTime = uint64(block.timestamp + day);
        else {
            roundInfo[gameId].endTime += increaseTimeBy();
        }

        buyersInfo[gameId][msg.sender] = buyer;
    }
    
    function winPricePool(
        uint32 _gameId
    ) public checkRoundEnded(gameId) nonReentrant  {
        if (msg.sender != lastBuyer[_gameId]) {
            revert MatrixErrors.Matrix3DErrors(MatrixErrors.Errors.NotWinner);
        }
        if (roundInfo[_gameId].rewardReceivd) {
            revert MatrixErrors.Matrix3DErrors(
                MatrixErrors.Errors.RewardAlreadyReceivd
            );
        }
        uint amount = roundInfo[_gameId].winningAmount;
        roundInfo[_gameId].rewardReceivd = true;
        USDB.transfer(msg.sender, amount);
    }
    
    function getNftsReward(address user) public {
        claimMyContractsGas();
        pillNftRewardContract.getReward(user);
        
    }
    function stake(
        uint amount

    ) public nonReentrant{
        address stakingAddress = StakingContracts[gameId];
        IERC20(MatrixToken).transferFrom(msg.sender,address(this),amount);
        IERC20(MatrixToken).approve(stakingAddress,amount);
        IMatrixStaking(stakingAddress).stake(msg.sender,amount);
    }
    function getSourceTokenHoldersReward(
        uint32 _gameId,
        uint32 _positionId
    ) public nonReentrant{
        address stakingAddress = StakingContracts[_gameId];
        IMatrixStaking(stakingAddress).unstake(_positionId);
    }
    function claimMyContractsGas() internal {
        BLAST.claimAllGas(address(this), address(pillNftRewardContract));
    }

    // ? --------------- HELPER FUNCTIONS ---------------- ? //

    function pay(
        address user,
        uint amount,
        Pill _pill,
        uint32 _count
    ) internal returns (Buyers memory) {
        roundInfo[gameId].totalSupply += amount / 2;
        USDB.transfer(deusExMachina, amount / 10);
        Buyers memory buyer = buyersInfo[gameId][user];
        if (_pill == Pill.RedPill) {
            buyer.redPillCount += _count;
            roundInfo[gameId].totalRedPillBuyed += _count;
            USDB.approve(address(pillNftRewardContract), amount / 25);
            // pillNftRewardContract.updateState(amount / 25, _count, user);
            USDB.approve(address(StakingContract), amount / 15);
            // StakingContract.addReward(amount / 15);
        } else {
            roundInfo[gameId].totalBluePillBuyed += _count;
            buyer.bluePillCount += _count;
            USDB.approve(address(pillNftRewardContract), amount / 15);
            // pillNftRewardContract.updateState(amount / 15, _count, user);

            USDB.approve(address(StakingContract), amount / 25);
            // StakingContract.addReward(amount / 25);
        }
        insertTopThreeNFTHolders(buyer.bluePillCount+buyer.redPillCount,user);
        return buyer;
    }

    function countDown() public view returns (uint64) {
        return uint64(roundInfo[gameId].endTime - block.timestamp);
    }

    function pillPrice() public view returns (uint256) {
        if (roundInfo[gameId].totalSupply < startPrice) {
            return 1e18;
        }

        return roundInfo[gameId].totalSupply / (startPrice / 1e18);
    }
    function increaseTimeBy() public view returns (uint8) {
        uint8 index = 0;
        for (uint8 i = 0; i < amountsRanges.length; i++) {
            if (roundInfo[gameId].totalSupply > amountsRanges[i]) {
                index = i;
            }
        }
        return increasedTime[index];
    }

    function timestamp() public view returns (uint) {
        return block.timestamp;
    }
    

    function insertTopThreeNFTHolders(uint256 number,address user) internal {
        if (number > topThreeNFTs[0]) {
            topThreeNFTs[2] = topThreeNFTs[1];
            topThreeUsers[2]=topThreeUsers[1];
            topThreeNFTs[1] = topThreeNFTs[0];
            topThreeUsers[1]=topThreeUsers[0];
            topThreeNFTs[0] = number;
            topThreeUsers[0]=user;
        } else if (number > topThreeNFTs[1]) {
            topThreeNFTs[2] = topThreeNFTs[1];
            topThreeUsers[2]=topThreeUsers[1];
            topThreeNFTs[1] = number;
            topThreeUsers[1]=user;
        } else if (number > topThreeNFTs[2]) {
            topThreeNFTs[2] = number;
            topThreeUsers[2]=user;
        }
    }
}
