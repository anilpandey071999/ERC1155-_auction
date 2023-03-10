import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Auction, Auction__factory } from "../typechain-types"

describe("Auction", function () {
    async function deployAuction() {
        const [user1, user2, user3] = await ethers.getSigners();
        const AuctionContract: Auction__factory = await ethers.getContractFactory("Auction");
        const auctionContract: Auction = await AuctionContract.deploy();

        return { auctionContract, user1, user2, user3 }
    }

    describe("Auction", function () {
        it("Mint ERC1155", async function () {
            const { auctionContract, user1, user2, user3 } = await deployAuction();
            await auctionContract.mint(user1.address, 1)

            expect(await (await auctionContract.balanceOf(user1.address, 1)).toString()).to.be.equal("1")
        })

        it("Create Auction", async function () {
            const { auctionContract, user1, user2, user3 } = await deployAuction();
            const tokenId = 1;
            await auctionContract.mint(user1.address, 1)

            expect(await (await auctionContract.balanceOf(user1.address, tokenId)).toString()).to.be.equal("1")
            const ONE_HOURS_IN_SECS = 1 * 60 * 60;
            await auctionContract.createAuction(tokenId, 1, (await time.latest()) + ONE_HOURS_IN_SECS, ethers.utils.parseEther("0.15"));
            
            // console.log(user1.address,(await (await auctionContract.auctions(1)).artist) );
            
            expect(await (await (await auctionContract.auctions(1)).artist)).to.be.equal(user1.address)
        })


    })
})