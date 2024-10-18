// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Card.sol";

contract Collection {
    string public name;
    uint256 public cardCount;
    address public owner;
    mapping(uint256 => Card) public cards;

    constructor(string memory _name, uint256 _cardCount, address _owner) {
        name = _name;
        cardCount = _cardCount;
        owner = _owner;
    }

    function addCard(uint256 cardId, string memory cardName) public {
        require(msg.sender == owner, "Only the owner can add cards.");
        Card newCard = new Card(cardId, cardName, owner);
        cards[cardId] = newCard;
    }

    function getCard(uint256 cardId) public view returns (Card) {
        return cards[cardId];
    }

    function getAllCards() public view returns (Card[] memory) {
        Card[] memory allCards = new Card[](cardCount);
        for (uint256 i = 0; i < cardCount; i++) {
            allCards[i] = cards[i];
        }
        return allCards;
    }
}
