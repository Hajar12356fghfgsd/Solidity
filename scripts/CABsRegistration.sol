pragma solidity ^0.8.0;

contract CABRegistration {
    // Struct to represent CAB
    struct CAB {
        string name;
        address EA;
        string ipfsHash; // IPFS hash for CAB data
        bool registered;
    }

    // Mapping from Ethereum address to CAB
    mapping(address => CAB) public cabs;

    // Event to emit when CAB is registered
    event CABRegistered(string name, address EA, string ipfsHash);

    // Function to register CAB
    function registerCAB(string memory _name, string memory _ipfsHash) public {
        // Ensure CAB with the given address does not already exist
        require(!cabs[msg.sender].registered, "CAB with this address already exists");

        // Create new CAB instance
        CAB memory newCAB = CAB(_name, msg.sender, _ipfsHash, true);

        // Add CAB to mapping
        cabs[msg.sender] = newCAB;

        // Emit event
        emit CABRegistered(_name, msg.sender, _ipfsHash);
    }

    // Function to get CAB details
    function getCABDetails(address _EA) public view returns (string memory, string memory, bool) {
        CAB memory cab = cabs[_EA];
        require(cab.registered, "CAB with this address does not exist");
        return (cab.name, cab.ipfsHash, cab.registered);
    }
}