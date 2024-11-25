const {ethers} = require("hardhat");
const { expect } = require('chai');

const {expectRevert, time} = require('@openzeppelin/test-helpers')
const sinon = require('sinon');
const clock = sinon.useFakeTimers();

  let impersonateAccount;
  let impersonateAddress;
  let SourceToken
  let ContractUSDB;
  let MatrixNFTContract;
  let Matrix;
describe("MatrixGame", async () => {

  it("Initialize Contracts", async function () {
    const signers=await ethers.getSigners();

    
    


    // ?---------------- Deploying NFT ----------------? //
    const MatrixSourceTokenContract = await ethers.getContractFactory("MatrixSourceToken");

    const MatrixSourceToken = await MatrixSourceTokenContract.deploy("1000000000000");
    
    SourceToken=MatrixSourceToken;
    // ?---------------- Deploying USDB ----------------? //

    const USDBContract = await ethers.getContractFactory("USDB");

    const USDB = await USDBContract.deploy("1000000000000");
    
    ContractUSDB=USDB;


    // ?---------------- Depploying NFT ----------------? //

    const NFTContract = await ethers.getContractFactory("Matrix3DNFT");
    const NFT = await NFTContract.deploy("nft");
    MatrixNFTContract=NFT;

    // ?---------------- Deploying Matrix ----------------? //


    const MatrixStakingContract = await ethers.getContractFactory("MatrixStaking");

    const MatrixStaking = await MatrixStakingContract.deploy();
    MatrixStaking.initialize(await MatrixSourceToken.getAddress(),await USDB.getAddress());
    // ?---------------- Deploying Matrix ----------------? //

    
    

    const Contract = await ethers.getContractFactory("Matrix3D");
    const Matrix3D = await Contract.deploy(signers[1],signers[2],await MatrixStaking.getAddress(),await NFT.getAddress(),await MatrixSourceToken.getAddress(),await USDB.getAddress());

    // ?---------------- initialize Matrix Game ----------------? //

    await NFT.connect(signers[0]).initailizeMatrix(await Matrix3D.getAddress())
    await USDB.connect(signers[0]).approve(await Matrix3D.getAddress(),ethers.parseEther("100000"))

    // ?---------------- Deploying USDB ----------------? //

    const GetNftRewardContract = await ethers.getContractFactory("GetNftReward");

    const GetNftReward = await GetNftRewardContract.deploy(await Matrix3D.getAddress(),await USDB.getAddress());
    
    

await MatrixStaking.transferOwnership(await Matrix3D.getAddress())
    
    await Matrix3D.initializeGame(await GetNftReward.getAddress())
    Matrix=Matrix3D;


    
  });

// it("win should revert", async function () {
//     const signers=await ethers.getSigners();
//     await ContractUSDB.connect(signers[0]).approve(await Matrix.getAddress(),ethers.parseEther("100000000000000000"))
//     await Matrix.connect(signers[0]).buyPill(1,1,"0x0000000000000000000000000000000000000000")
//     await Matrix.connect(signers[0]).winPricePool(1)
//     await expectRevert(await Matrix.winPricePool(1),"Matrix3DErrors(2)")
//     await expectRevert(
//       Matrix.winPricePool(1),
//       "custom error 'Matrix3DErrors(2)'"
//     );
//     console.log(tx);

//   }).timeout(60000);;

  // it(" 1,000,000 USDB  => increased by 1", async function () {

  //   let res=await Matrix.roundInfo(1);
  //   console.log(res[1]);

  //   await fuzzingTest()
  //   await Matrix.roundInfo(1);

    

  // }).timeout(100000);;


  it("win", async function () {
    const signers=await ethers.getSigners();

    await ContractUSDB.connect(signers[0]).approve(await Matrix.getAddress(),ethers.parseEther("100000000000000000"))

    await Matrix.connect(signers[0]).buyPill(1,1,"0x0000000000000000000000000000000000000000")
    let s=await Matrix.timestamp()
    let end=await Matrix.roundInfo(0);
    // console.log(end[1]);
    // console.log(s);
    // console.log(s>end[1]);
    let time=Number(end[1])-Number(s)
    console.log(time);
    // const customDate = new Date(2024, 1, 21, 12, 30, 0, 0);
    // console.log("Custom Date:", customDate);

    
    // console.log(tx);
// 
// console.log(Date.now());

// clock.setTimeout(async ()=>{
//         await Matrix.connect(signers[0]).winPricePool(0)
//         s=await Matrix.timestamp()  
//         end=await Matrix.roundInfo(0);
//         console.log(end[1]);
//         console.log(s);
//         console.log(s>end[1]);
//         console.log('Transaction sent after 1 day');
// }, time * 1000)
//     clock.tick(time * 1000);
// console.log(Date.now());
    
    // setTimeout(async function() {
      // Send transaction here

    // }, time-864000000 ); // 1 day in milliseconds

    // Fast-forward time by 1 day
    // clock.tick(time * 1000);
    
    // await Matrix.connect(signers[0]).winPricePool(0)
  });
  // it("win2", async function () {
  //   const signers=await ethers.getSigners();
  //   await Matrix.connect(signers[0]).getNftsReward(1)
    
  // });
  clock.restore();

});

async function fuzzingTest() {
    const signers=await ethers.getSigners();

  for (let index = 0; index < 20; index++) {
    await ContractUSDB.connect(signers[index]).approve(await Matrix.getAddress(),ethers.parseEther("100000000000000000"))
    await ContractUSDB.connect(signers[index]).mint(signers[index].address,ethers.parseEther("100000000000000000"))
    
    for (let j = 0; j < 100; j++) {
      let nftcount=getRandomInt(500,700)
      let nft=getRandomInt(0,1)
      let res=await Matrix.roundInfo(1);
      let time=await Matrix.increaseTimeBy();
      let balance=await ContractUSDB.balanceOf(Matrix.getAddress())

    //   // Send transaction here
        await Matrix.connect(signers[index]).buyPill(nft,nftcount,"0x0000000000000000000000000000000000000000")
      }
      
      

      
      
      

      

    
  }
  
      

}

// function generateRandom(min, max) {
function getRandomInt(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// 1708594079n
// 1708654079n

// 1708514965- 1708621385
