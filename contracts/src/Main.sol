pragma solidity ^0.8.0;

import "./Card.sol";
import "./Collection.sol";
import "./ownable.sol";

contract Main is Ownable {
    uint256 private collectionCount;
    mapping(uint256 => Collection) private collections;
    uint256 public boosterPrice = 0.001 ether; // Prix pour ouvrir un booster
    event transfer(address _from,address _to,uint _cardId);
    constructor() {
        collectionCount = 0;
        createDefaultCollection(); // Appel à la fonction pour créer une collection par défaut
    }

    modifier onlyOwnerOf(uint _cardId, Collection _collection) {
        require(msg.sender == _collection.cardToOwner(_cardId), "You do not own this card");
        _;
    }

    function createCollection(string calldata name, uint256 maxCardCount) external onlyOwner {
        collections[collectionCount] = new Collection(name, maxCardCount, address(this), collectionCount);
        collectionCount++;
    }

    function getCollection(uint256 collectionId) external view returns (Collection) {
        return collections[collectionId];
    }


    function openBooster() external payable {
        require(msg.value == boosterPrice, "Insufficient Ether sent, booster costs 0.001 ETH");

        uint256 availableCardsCount = 0;
        for (uint i = 0; i < collectionCount; i++) {
            availableCardsCount += collections[i].getAvailableCardsCount();
        }

        require(availableCardsCount >= 2, "Not enough available cards");

        uint256 cardsAssigned = 0;

        for (uint i = 0; i < collectionCount && cardsAssigned < 2; i++) {
            Collection collection = collections[i];
            uint256[] memory availableCards = collection.getAvailableCards();

            for (uint j = 0; j < availableCards.length && cardsAssigned < 2; j++) {
                uint cardId = availableCards[j];
                collection.assignCardToOwner(cardId, msg.sender); // Assigne la carte au joueur
                cardsAssigned++;
            }
        }
    }

    function achat(uint _cardId, Collection _collection) public payable onlyOwnerOf(_cardId,_collection){
        Card _card = collections[_collection.collectionId()].cards(_cardId);
        address _oldOwner = _card.owner();
        require(_card.availability() == true && _card.prix() ==msg.value);
        _card.changeOwner(msg.sender);
        collections[_collection.collectionId()].changeOwner(_cardId, msg.sender); // Assigne la carte au joueur
        _card.changeAvailability();
        emit transfer(_oldOwner,msg.sender,_cardId);
    }

    function mintCard(uint256 _collectionId, uint256 _cardId, address _to) external {
        // Vérifiez que l'appelant est le propriétaire ou a la permission de mint
        require(msg.sender == owner, "Only the owner can mint cards");

        // Vérifiez que la collection existe
        Collection collection = collections[_collectionId];
        require(collection.collectionId() == _collectionId, "Collection does not exist");

        // Vérifiez que la carte existe dans la collection
        Card card = collection.cards(_cardId);
        require(card.id()== _cardId, "Card does not exist");

        // Attribuez la carte à l'utilisateur
        collection.assignCardToOwner(_cardId,_to);
    }


    function createDefaultCollection() internal {
        // Créez une collection par défaut
        Collection newCollection = new Collection("Default Collection", 10, address(this), collectionCount);
        collections[collectionCount] = newCollection;

        // Incrémentez le compteur de collection
        collectionCount++;
    }

    function CollectionCounter() public view returns(uint){
        return collectionCount;
    }

    function getCollectionInformation(uint256 _collectionId) public view returns (string memory name, uint256 maxCardCount, uint256 collectionId)
    {
        Collection collection = collections[_collectionId];
        return (collection.name(), collection.maxCardCount(), collection.collectionId());
    }

    function getCardDetails(uint256 collectionId, uint256 cardId) public view returns (
        uint256 id,
        string memory name,
        address owner,
        uint prix,
        bool availability
    ) {
        require(collectionId < collectionCount, "Collection does not exist.");
        Collection collection = collections[collectionId];
        require(cardId < collection.maxCardCount(), "Card does not exist.");

        Card  card = collection.cards(cardId);
        return (card.id(), card.name(), card.owner(), card.prix(), card.availability());
    }
    function getCardsByOwner(address owner) public view returns (uint256[] memory cardIds , uint256[] memory collectionIds) {
        uint256 totalCollections = collectionCount;

        uint256 count = 0;

        for (uint256 i = 0; i < totalCollections; i++) {
            Collection collection = collections[i];
            uint256 maxCardCount = collection.maxCardCount();

            for (uint256 j = 0; j < maxCardCount; j++) {
                Card card = collection.cards(j);

                if (card.getOwner() == owner) {
                    cardIds[count] = j;
                    collectionIds[count] = i;
                    count++;
                }
            }
        }

        return (cardIds, collectionIds);
    }

}
