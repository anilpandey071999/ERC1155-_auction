// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "hardhat/console.sol";

contract Auction is ERC1155, Ownable {
    IERC20 token;
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
        uint256 totalBalance;
    }
    mapping(uint256 => mapping(uint32 => Bidder)) biddings;
    mapping(address => bool) isBidded;

    mapping(uint256 => AuctionIteam) public auctions;

    uint256 public auctionId = 1;
    uint256 public tokenId = 1;
    uint32 public maxBid = 10;

    constructor(IERC20 _token) ERC1155("") {
        token = _token;
    }

    /**
     * @param amount is total supply of token id as it ERC1155 is the combile of ERC20 and ERC721
     */
    function mint(uint256 amount) public {
        _mint(msg.sender, tokenId, amount, "");
        tokenId = tokenId + 1;
    }

    /**
     * @param id is a token id
     * @param numberOfToken number of token will be auctioned of the same token 1d
     * @param auctionDuration is an auction duration
     * @param minmumAmount an minmum amount of bid
     */
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
        auctionIteam.totalBid = 1;
        auctionIteam.auctionOpen = true;
        auctionIteam.startingTime = block.timestamp;
        auctionIteam.auctionDuration = auctionDuration;

        auctionIteam.totalBalance = 0;

        auctionId = auctionId + 1;
    }

    function newBid(uint256 _auctionId, uint amount) public  {
        AuctionIteam storage auctionIteam = auctions[_auctionId];
        require(!isBidded[msg.sender], "You have already placed you bid");
        require(
            amount >= auctionIteam.minmumPrice,
            "amount should not be less then minmum value"
        );
        uint256 auctionEndTime = auctionIteam.startingTime +
            auctionIteam.auctionDuration;
        require(auctionEndTime > block.timestamp, "Auction Ended");
        if (auctionIteam.totalBid > maxBid) {
            (
                uint256 lowestBid,
                address lowestBidder,
                uint32 lowestBidderIndex
            ) = findLowestBider(_auctionId);
            auctionIteam.totalBalance = auctionIteam.totalBalance - lowestBid;
           Withdraw(lowestBidder ,lowestBid);
           deposit(msg.sender,amount);
            biddings[_auctionId][lowestBidderIndex] = Bidder(
                msg.sender,
                amount
            );

        } else {
            deposit(msg.sender,amount);
            biddings[_auctionId][auctionIteam.totalBid] = Bidder(
                msg.sender,
                amount
            );
        }
        auctionIteam.totalBalance = auctionIteam.totalBalance + amount;
        auctionIteam.totalBid = auctionIteam.totalBid + 1;
        isBidded[msg.sender] = true;
    }


    function findLowestBider(
        uint256 _auctionId
    )
        internal
        view
        returns (
            uint256 lowestBid,
            address lowestBidder,
            uint32 lowestBidderIndex
        )
    {
        // AuctionIteam storage auctionIteam = auctions[auctionId];
        uint256 _lowestBid = biddings[_auctionId][1].bidAmount;
        address _lowestBidder = biddings[_auctionId][1].bidder;
        uint32 _lowestBidderIndex = 1;
        for (uint32 i = 1; i <= maxBid; i++) {
            if (_lowestBid > biddings[_auctionId][i].bidAmount) {
                _lowestBid = biddings[_auctionId][i].bidAmount;
                _lowestBidder = biddings[_auctionId][i].bidder;
                _lowestBidderIndex = i;
            }
        }
        return (_lowestBid, _lowestBidder, _lowestBidderIndex);
    }

    function findHightestBider(
        uint256 _auctionId
    )
        internal
        view
        returns (
            uint256 hightestBid,
            address hightestBidder,
            uint32 hightestBidderIndex
        )
    {
        // AuctionIteam storage auctionIteam = auctions[auctionId];
        uint256 _hightestBid = 0;
        address _hightestBidder = address(0);
        uint32 _hightestBidderIndex = 0;
        for (uint32 i = 1; i <= maxBid; i++) {
            if (_hightestBid < biddings[_auctionId][i].bidAmount) {
                _hightestBid = biddings[_auctionId][i].bidAmount;
                _hightestBidder = biddings[_auctionId][i].bidder;
                _hightestBidderIndex = i;
            }
        }
        return (_hightestBid, _hightestBidder, _hightestBidderIndex);
    }

    function endAuction(uint256 _auctionId) public {
        AuctionIteam storage auctionIteam = auctions[_auctionId];
        require(
            auctionIteam.artist == msg.sender,
            "Only artist of the auction can call this function"
        );
        uint256 auctionEndTime = auctionIteam.startingTime +
            auctionIteam.auctionDuration;
        require(auctionEndTime <= block.timestamp, "Auction has not Ended yet");
        (uint256 hightestBid, address hightestBidder, ) = findHightestBider(
            _auctionId
        );
        IERC1155(address(this)).safeTransferFrom(
            msg.sender,
            hightestBidder,
            auctionIteam.tokenId,
            auctionIteam.numberOfToken,
            ""
        );

        auctionIteam.auctionOpen = false;

        for (uint32 i = 1; i <= maxBid; i++) {
            if (biddings[_auctionId][i].bidder != hightestBidder) {
                Withdraw(
                    biddings[_auctionId][i].bidder,
                    biddings[_auctionId][i].bidAmount
                );
            } else {
                Withdraw(auctionIteam.artist, hightestBid);
            }
        }
    }

    function getMyBid(
        uint256 _auctionId
    ) external view returns (uint256 myBid) {
        // AuctionIteam storage auctionIteam = auctions[_auctionId];
        for (uint32 i = 1; i <= maxBid; i++) {
            if (msg.sender == biddings[_auctionId][i].bidder) {
                myBid = biddings[_auctionId][i].bidAmount;
            }
        }
        return myBid;
    }

    function changeMaxBid(uint32 _maxBid) external onlyOwner {
        maxBid = _maxBid;
    }

    mapping(address => uint256) public userbalance;

    function deposit(address sender, uint256 amount) internal {
        token.transferFrom(sender, address(this), amount);
        userbalance[sender] = amount;
    }

    function Withdraw(address sender,uint256 amount) internal {
        token.transfer(sender, amount);
    }
}
