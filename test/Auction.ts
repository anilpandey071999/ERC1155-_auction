import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Auction, Auction__factory, MyToken, MyToken__factory } from "../typechain-types"

describe("Auction", function () {
    async function deployAuction() {
        const [user1, user2, user3] = await ethers.getSigners();
        const ERC20Token: MyToken__factory = await ethers.getContractFactory("MyToken")
        const erc20Token: MyToken = await ERC20Token.deploy();
        const AuctionContract: Auction__factory = await ethers.getContractFactory("Auction");
        const auctionContract: Auction = await AuctionContract.deploy(erc20Token.address);

        await erc20Token.connect(user1).mint(ethers.utils.parseEther("150"))
        await erc20Token.connect(user1).approve(auctionContract.address,ethers.utils.parseEther("150"))
        await erc20Token.connect(user2).mint(ethers.utils.parseEther("150"))
        await erc20Token.connect(user2).approve(auctionContract.address,ethers.utils.parseEther("150"))
        await erc20Token.connect(user3).mint(ethers.utils.parseEther("150"))
        await erc20Token.connect(user3).approve(auctionContract.address,ethers.utils.parseEther("150"))

        return { auctionContract, erc20Token, user1, user2, user3 }
    }

    describe("Auction", function () {
        it("Mint ERC1155", async function () {
            const { auctionContract, erc20Token, user1, user2, user3 } = await deployAuction();
            await auctionContract.mint(1)

            expect(await (await auctionContract.balanceOf(user1.address, 1)).toString()).to.be.equal("1")
        })

        it("Create Auction", async function () {
            const { auctionContract, user1, user2, user3 } = await deployAuction();
            const tokenId = 1;
            await auctionContract.mint(1)

            expect(await (await auctionContract.balanceOf(user1.address, tokenId)).toString()).to.be.equal("1")
            const ONE_HOURS_IN_SECS = 1 * 60 * 60;
            await auctionContract.createAuction(tokenId, 1, ONE_HOURS_IN_SECS, ethers.utils.parseEther("0.15"));
            
            // console.log(user1.address,(await (await auctionContract.auctions(1)).artist) );
            
            expect(await (await (await auctionContract.auctions(1)).artist)).to.be.equal(user1.address)
        })

        it("Place Bid", async function () {
            const { auctionContract,erc20Token, user1, user2, user3 } = await deployAuction();
            await auctionContract.mint(1)
            const tokenId = 1;

            const ONE_HOURS_IN_SECS = 1 * 60 * 60;
            const creatAuction =  await auctionContract.connect(user1).createAuction(tokenId, 1, (await time.latest()) + ONE_HOURS_IN_SECS, ethers.utils.parseEther("0.15"));
            await creatAuction.wait();

            
            const placebid = await auctionContract.connect(user2).newBid(1,ethers.utils.parseEther("0.16"))
            await placebid.wait()
            
            expect(await (await auctionContract.connect(user2).getMyBid(1)).toString()).to.be.equal(ethers.utils.parseEther("0.16").toString())
        })

        it("Placeing MAX Bid", async function () {
            const { auctionContract,erc20Token, user1, user2, user3 } = await deployAuction();
            const [,,,user4, user5, user6, user7, user8, user9, user10, user11] = await ethers.getSigners()
            await erc20Token.connect(user4).mint(ethers.utils.parseEther("150"))
            await erc20Token.connect(user4).approve(auctionContract.address,ethers.utils.parseEther("150"))
            await erc20Token.connect(user5).mint(ethers.utils.parseEther("150"))
            await erc20Token.connect(user5).approve(auctionContract.address,ethers.utils.parseEther("150"))
            await erc20Token.connect(user6).mint(ethers.utils.parseEther("150"))
            await erc20Token.connect(user6).approve(auctionContract.address,ethers.utils.parseEther("150"))
            await erc20Token.connect(user7).mint(ethers.utils.parseEther("150"))
            await erc20Token.connect(user7).approve(auctionContract.address,ethers.utils.parseEther("150"))
            await erc20Token.connect(user8).mint(ethers.utils.parseEther("150"))
            await erc20Token.connect(user8).approve(auctionContract.address,ethers.utils.parseEther("150"))
            await erc20Token.connect(user9).mint(ethers.utils.parseEther("150"))
            await erc20Token.connect(user9).approve(auctionContract.address,ethers.utils.parseEther("150"))
            await erc20Token.connect(user10).mint(ethers.utils.parseEther("150"))
            await erc20Token.connect(user10).approve(auctionContract.address,ethers.utils.parseEther("150"))
            await erc20Token.connect(user11).mint(ethers.utils.parseEther("150"))
            await erc20Token.connect(user11).approve(auctionContract.address,ethers.utils.parseEther("150"))
            await auctionContract.mint(1)
            const tokenId = 1;

            const ONE_HOURS_IN_SECS = 1 * 60 * 60;
           const creatAuction =  await auctionContract.connect(user1).createAuction(tokenId, 1, (await time.latest()) + ONE_HOURS_IN_SECS, ethers.utils.parseEther("0.15"));
            await creatAuction.wait();
            const user1Placebid = await auctionContract.connect(user1).newBid(1, ethers.utils.parseEther("1"))
            await user1Placebid.wait()
            const user2Placebid = await auctionContract.connect(user2).newBid(1,ethers.utils.parseEther("0.17"))
            await user2Placebid.wait()
            const user2Balance = parseInt(await (await erc20Token.balanceOf(user2.address)).toString())
            const usder3placebid = await auctionContract.connect(user3).newBid(1,ethers.utils.parseEther("0.18"))
            await usder3placebid.wait()
            const usder4placebid = await auctionContract.connect(user4).newBid(1,ethers.utils.parseEther("0.19"))
            await usder4placebid.wait()
            const usder5placebid = await auctionContract.connect(user5).newBid(1,ethers.utils.parseEther("0.20"))
            await usder5placebid.wait()
            const usder6placebid = await auctionContract.connect(user6).newBid(1,ethers.utils.parseEther("0.21"))
            await usder6placebid.wait()
            const usder7placebid = await auctionContract.connect(user7).newBid(1,ethers.utils.parseEther("0.22"))
            await usder7placebid.wait()
            const usder8placebid = await auctionContract.connect(user8).newBid(1,ethers.utils.parseEther("0.23"))
            await usder8placebid.wait()
            const usder9placebid = await auctionContract.connect(user9).newBid(1,ethers.utils.parseEther("0.24"))
            await usder9placebid.wait()
            const usder10placebid = await auctionContract.connect(user10).newBid(1,ethers.utils.parseEther("0.25"))
            await usder10placebid.wait()
            const usder11placebid = await auctionContract.connect(user11).newBid(1,ethers.utils.parseEther("0.26"))
            await usder11placebid.wait()
            const user2BalanceAfter = parseInt(await (await erc20Token.balanceOf(user2.address)).toString())
            
            expect(user2BalanceAfter).to.be.greaterThan(user2Balance)

            // expect(await (await auctionContract.connect(user2).getMyBid(1)).toString()).to.be.equal(ethers.utils.parseEther("0.15").toString())
        })

    })
})