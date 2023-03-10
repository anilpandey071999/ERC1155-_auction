// SPDX-License-Identifier= MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Auction is ERC1155 {
    /**
     * Bidder keeps the records of bidder details
     * bidder is the address of wallet placing bid
     * bidAmount is bidder ready to pay of the auctioned Iteam
     */
    struct Bidder {
        address bidder;
        uint256 bidAmount;
    }

    /**
     * ActionIteam is the keep the records of all the actioned iteams on throw this contract
     * artist is wallet address of artist
     * tokenId is ERC1155 token
     * numberofToken will the amount of the tokens
     * minmumPrice of the actioned iteam
     * totalbid will keep track of the total biding came for the iteam
     * auctionOpen is flage to check if auction is open or not
     * bidings is a map of top 10 bidder
     */
    struct AuctionIteam {
        address artist;
        uint256 tokenId;
        uint256 numberOfToken;
        uint256 minmumPrice;
        uint32 totalBid;
        bool auctionOpen;
        uint256 startingTime;
        uint256 auctionDuration;
        mapping(uint32 => Bidder) biddings;
    }

    mapping(uint256 => AuctionIteam) public auctions;

    uint256 auctionId = 1;
    uint256 tokenId = 1;

    constructor()ERC1155("https://game.example/api/item/{id}.json") {}

    function mint(address account, uint256 amount, bytes memory data) public {
        _mint(account, tokenId, amount, data);
        tokenId = tokenId + 1;
    }

    function createAuction(
        uint256 id,
        uint256 numberOfToken,
        uint256 auctionDuration,
        uint256 minmumAmount
    ) public {
        require(id > 0, "Invalide Token Id");
        require(minmumAmount > 0, "Minmum auction price cannot be ZERO");
        AuctionIteam storage auctionIteam = auctions[auctionId];
        auctionIteam.artist = msg.sender;
        auctionIteam.tokenId = id;
        auctionIteam.numberOfToken = numberOfToken;
        auctionIteam.minmumPrice = minmumAmount;
        auctionIteam.totalBid = 0;
        auctionIteam.auctionOpen = true;
        auctionIteam.startingTime = block.timestamp;
        auctionIteam.auctionDuration = auctionDuration;
    }

    /**
     * register the 1155 token
     * create an auction for the token
     * Place bidding in auction
     * place
     *
     */
}
