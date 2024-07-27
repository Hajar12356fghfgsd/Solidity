pragma solidity ^0.8.0;

contract BiddingContract {
    struct Auction {
        uint256 auctionId;
        address manufacturer;
        uint256 initialAmount;
        uint256 highestBidAmount;
        address highestBidder;
        string highestBidderName;
        uint256 startTime;
        uint256 endTime;
        bool exists;
        bool auctionActive;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCount;

    event AuctionCreated(uint256 auctionId, address manufacturer, uint256 initialAmount, uint256 startTime, uint256 endTime);
    event BidPlaced(uint256 auctionId, address cabAddress, string cabName, uint256 bidAmount);
    event AuctionEnded(uint256 auctionId, address highestBidder, string highestBidderName, uint256 highestBidAmount);

    // Constructor to restrict contract creation to the international accreditation entity
    constructor() {
        // Implement any authorization mechanism here if needed
        // Example: require(msg.sender == accreditationEntity, "Unauthorized contract deployment");
    }

    // Function for the manufacturer to create a new auction
    function createAuction(uint256 initialAmount, uint256 startTime, uint256 endTime) external {
        // Ensure the auction start time and end time are valid
        require(startTime < endTime, "Invalid auction duration");

        // Increment auction count for unique auction ID
        auctionCount++;

        // Create a new auction
        Auction storage auction = auctions[auctionCount];
        auction.auctionId = auctionCount;
        auction.manufacturer = msg.sender;
        auction.initialAmount = initialAmount;
        auction.highestBidAmount = initialAmount;
        auction.startTime = startTime;
        auction.endTime = endTime;
        auction.exists = true;
        auction.auctionActive = true;

        // Emit event for auction creation
        emit AuctionCreated(auctionCount, msg.sender, initialAmount, startTime, endTime);
    }

    // Function for CABs to place a bid
    function placeBid(uint256 auctionId, address cabAddress, string memory cabName, uint256 bidAmount) external {
        // Retrieve the auction
        Auction storage auction = auctions[auctionId];

        // Ensure the auction exists and is active
        require(auction.exists, "Auction does not exist");
        require(auction.auctionActive, "Auction is not active");

        // Ensure the bidding period is active
        require(block.timestamp >= auction.startTime && block.timestamp <= auction.endTime, "Bidding period is over");

        // Ensure the bid amount is higher than the current highest bid amount
        require(bidAmount > auction.highestBidAmount, "Bid amount is too low");

        // Update the highest bid amount, bidder, and bidder's name
        auction.highestBidAmount = bidAmount;
        auction.highestBidder = cabAddress;
        auction.highestBidderName = cabName;

        // Emit event for bid placed
        emit BidPlaced(auctionId, cabAddress, cabName, bidAmount);
    }

// Function to end the auction
    function endAuction(uint256 auctionId) external {
        // Retrieve the auction
        Auction storage auction = auctions[auctionId];

        // Ensure the auction exists and is active
        require(auction.exists, "Auction does not exist");
        require(auction.auctionActive, "Auction is not active");

        // Ensure the caller is the manufacturer
        require(msg.sender == auction.manufacturer, "Only the manufacturer can end the auction");

        // Ensure the auction has ended
        require(block.timestamp > auction.endTime, "Auction is still ongoing");

        // Deactivate the auction
        auction.auctionActive = false;

        // Emit event for auction end
        emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBidderName, auction.highestBidAmount);
    }
}
 
