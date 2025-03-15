# Decentralized Ad Auction Smart Contract

## 📌 Overview

The **Decentralized Ad Auction Smart Contract** allows advertisers to bid in **ETH** for an on-chain **ad slot**. The highest bidder gets their ad displayed, and if someone outbids them, the previous advertiser receives a refund. The ad remains active for a fixed duration, after which it can be reset for new bids.

---

## 🛠️ Features

✅ **On-Chain Ad Auction** – Highest bidder wins the ad slot.

✅ **Time-Based Ownership** – Ads expire after a set duration (default: 24 hours).

✅ **Refund System** – When a new bidder outbids the current advertiser, the previous bidder gets refunded.

✅ **Multiple Ad Slots** – Supports multiple ad slots, each managed separately.

✅ **Admin Withdrawals** – The contract owner can withdraw collected ETH.

---

## ⚙️ How It Works

1️⃣ **Advertisers Bid** – Calls `bidForAd(slotId, adContent)` with ETH to place a bid.

2️⃣ **If Outbid** – The previous highest bidder is refunded their ETH.

3️⃣ **Ad Remains Active** – The winning ad stays live for the defined duration (`auctionDuration`).

4️⃣ **Ad Expiry** – When time expires, `expireAd(slotId)` can be called to reset the slot.

5️⃣ **Owner Withdraws** – The contract owner can withdraw collected ETH via `withdraw()`.

---

## 📜 Smart Contract Code (Solidity)

```solidity
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

    event NewHighestBid(uint256 indexed slotId, address bidder, uint256 amount, string adContent);
    event AdExpired(uint256 indexed slotId, address previousBidder, uint256 refundAmount);

    constructor() {
        owner = msg.sender;
    }

    function bidForAd(uint256 slotId, string memory adContent) external payable {
        AdSlot storage slot = adSlots[slotId];
        require(msg.value > slot.highestBid, "Bid must be higher than the current highest");

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
        delete adSlots[slotId];
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
```

---

## 📦 Installation & Deployment

### 1️⃣ **Install Dependencies** (Optional for testing)

If you're using **Hardhat** or **Remix**, install the necessary dependencies:

```sh
npm install hardhat ethers dotenv
```

### 2️⃣ **Compile the Contract**

```sh
npx hardhat compile
```

### 3️⃣ **Deploy on Ethereum Testnet**

Modify the deploy script and deploy using Hardhat:

```sh
npx hardhat run scripts/deploy.js --network goerli
```

For **Remix**, simply paste the code and deploy using **Injected Web3 (MetaMask)**.

---

## 📡 Interacting with the Contract

### **Bid for an Ad Slot**

```js
await contract.bidForAd(1, "Buy Crypto Safely with XYZ Exchange", {
  value: ethers.utils.parseEther("0.1"),
});
```

### **Expire an Ad Slot**

```js
await contract.expireAd(1);
```

### **Withdraw Contract Balance**

```js
await contract.withdraw();
```

---

## 📜 License

This project is licensed under the **MIT License**. You are free to use, modify, and distribute this project as per the terms of the license.
