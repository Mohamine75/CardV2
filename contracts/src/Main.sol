// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Collection.sol";
import "./Card.sol";

contract Main {
    mapping(uint256 => Collection) public collections;
    mapping(address => Card[]) public playerCards;
    uint256 public collectionCounter = 0;
    uint256 public boosterPrice = 0.001 ether;

    event CollectionCreated(uint256 collectionId, string name, uint256 cardCount);
    event BoosterOpened(address player, Card[] cards);

    function createCollection(string memory name, uint256 cardCount) public {
        Collection newCollection = new Collection(name, cardCount, msg.sender);
        collections[collectionCounter] = newCollection;
        emit CollectionCreated(collectionCounter, name, cardCount);
        collectionCounter++;
    }

    function openBooster() public payable {
        require(msg.value >= boosterPrice, "Insufficient ether sent.");
        require(playerCards[msg.sender].length + 2 <= 10, "Max 10 cards allowed per player.");

        uint256 randomId1 = _getRandomCardId();
        uint256 randomId2 = _getRandomCardId();

        playerCards[msg.sender].push(_getRandomCard(randomId1));
        playerCards[msg.sender].push(_getRandomCard(randomId2));

        emit BoosterOpened(msg.sender, playerCards[msg.sender]);
    }

    function getCardsByOwner(address owner) public view returns (Card[] memory) {
        return playerCards[owner];
    }

    function _getRandomCard(uint256 cardId) internal view returns (Card memory) {
        Collection memory randomCollection = collections[cardId % collectionCounter];
        return randomCollection.getCard(cardId % randomCollection.cardCount());
    }

    function _getRandomCardId() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % collectionCounter;
    }
}
