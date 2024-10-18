pragma solidity ^0.8.0;

import "./Card.sol";

contract Collection {
    string public name;
    uint256 public maxCardCount;
    uint256 public collectionId;
    Card[] public cards;

    mapping(uint256 => address) public cardToOwner;

    constructor(
        string memory _name,
        uint256 _maxCardCount,
        address mainContract,
        uint256 _collectionId
    ) {
        name = _name;
        maxCardCount = _maxCardCount;
        collectionId = _collectionId;

        // Création des cartes dans la collection, sans propriétaire initial
        for (uint256 i = 0; i < maxCardCount; i++) {
            cards.push(new Card(i, "Nom",  msg.sender));
        }
    }

    // Fonction pour récupérer les cartes non attribuées
    function getAvailableCards() public view returns (uint256[] memory) {
        uint256 availableCount = getAvailableCardsCount();
        uint256[] memory result = new uint256[](availableCount);
        uint256 counter = 0;

        for (uint256 i = 0; i < cards.length; i++) {
            if (cardToOwner[i] == address(0)) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    // Nombre de cartes disponibles
    function getAvailableCardsCount() public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < cards.length; i++) {
            if (cardToOwner[i] == address(0)) {
                count++;
            }
        }
        return count;
    }

    // Assigner une carte à un propriétaire
    function assignCardToOwner(uint256 _cardId, address _owner) external {
        require(cardToOwner[_cardId] == address(0), "Card is already owned");
        cardToOwner[_cardId] = _owner;
        cards[_cardId].changeOwner(_owner); // Appel à la fonction du contrat Card
    }
}
