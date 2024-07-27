pragma solidity ^0.8.0;

contract EquipmentRegistration {

// Struct to represent a record to keep track of the equipment
struct Equipment {
string name;
uint256 id;
address EA;
string ipfsHash; // IPFS hash for equipment documents
bool registered;
}

// Mapping from equipment ID to Equipment
mapping(uint256 => Equipment) public equipments;

// Event to emit when equipment is registered
event EquipmentRegistered(uint256 id, string name, address EA, string ipfsHash);

// Function to register equipment
function registerEquipment(uint256 _id, string memory _name, string memory _ipfsHash) public {

require(!equipments[_id].registered, "Equipment with this ID already exists");         // Ensure equipment with the given ID does not already exist
Equipment memory newEquipment = Equipment(_name, _id, msg.sender, _ipfsHash, true);   // Create new equipment instance

// Add equipment to mapping
equipments[_id] = newEquipment; 

// emit event 
emit EquipmentRegistered(_id, _name, msg.sender, _ipfsHash);
}

// Function to get equipment details
function getEquipmentDetails(uint256 _id) public view returns (string memory, address, string memory, bool) {
Equipment memory equipment = equipments[_id];
require(equipment.registered, "Equipment with this ID does not exist");
return (equipment.name, equipment.EA, equipment.ipfsHash, equipment.registered);

}

}