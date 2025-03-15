// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AdAuction {
    struct AdSlot {
        address highestBidder;
        uint256 highestBid;
        string adContent;
        uint256 expiryTime;
    }

    address public owner;
    uint256 public auctionDuration = 1 days; // Ad duration
    mapping(uint256 => AdSlot) public adSlots; // Multiple ad slots

    event NewHighestBid(
        uint256 indexed slotId,
        address bidder,
        uint256 amount,
        string adContent
    );
    event AdExpired(
        uint256 indexed slotId,
        address previousBidder,
        uint256 refundAmount
    );

    constructor() {
        owner = msg.sender;
    }

    function bidForAd(
        uint256 slotId,
        string memory adContent
    ) external payable {
        AdSlot storage slot = adSlots[slotId];

        require(
            msg.value > slot.highestBid,
            "Bid must be higher than the current highest"
        );

        // Refund the previous highest bidder
        if (slot.highestBidder != address(0)) {
            payable(slot.highestBidder).transfer(slot.highestBid);
        }

        // Update ad slot with new highest bid
        slot.highestBidder = msg.sender;
        slot.highestBid = msg.value;
        slot.adContent = adContent;
        slot.expiryTime = block.timestamp + auctionDuration;

        emit NewHighestBid(slotId, msg.sender, msg.value, adContent);
    }

    function expireAd(uint256 slotId) external {
        AdSlot storage slot = adSlots[slotId];

        require(block.timestamp >= slot.expiryTime, "Ad slot is still active");

        emit AdExpired(slotId, slot.highestBidder, slot.highestBid);

        // Reset ad slot
        delete adSlots[slotId];
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
