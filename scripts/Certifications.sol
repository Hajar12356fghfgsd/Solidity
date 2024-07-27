pragma solidity ^0.8.0;

contract CertificationContract {
    // Struct to represent accreditation request
    struct AccreditationRequest {
        uint256 equipmentId;
        address manufacturer;
        address cab;
        string accreditationStatus; // Changed to string
        bool exists;
    }

    // Struct to represent certification request
    struct CertificationRequest {
        uint256 equipmentId;
        address manufacturer;
        address cab;
        string accreditationStatus; // Changed to string
        string certificationStatus; // Changed to string
        bool exists;
    }

    // Mapping from equipment ID to accreditation requests
    mapping(uint256 => AccreditationRequest) public accreditationRequests;

    // Mapping from equipment ID to certification requests
    mapping(uint256 => CertificationRequest) public certificationRequests;

    // Event to emit when an accreditation request is created
    event AccreditationRequestCreated(uint256 equipmentId, address manufacturer, address cab);

    // Event to emit when a certification request is created
    event CertificationRequestCreated(uint256 equipmentId, address manufacturer, address cab);

    // Event to emit when an accreditation decision is made
    event AccreditationDecisionMade(uint256 equipmentId, string decision);

    // Event to emit when a certification decision is made
    event CertificationDecisionMade(uint256 equipmentId, string decision);

    // Function for a manufacturer to create an accreditation request
    function createAccreditationRequest(uint256 _equipmentId, address _cab) public {
        // Ensure there is no existing accreditation request for the given equipment ID
        require(!accreditationRequests[_equipmentId].exists, "Accreditation request already exists");

        // Create a new accreditation request
        accreditationRequests[_equipmentId] = AccreditationRequest({
            equipmentId: _equipmentId,
            manufacturer: msg.sender,
            cab: _cab,
            accreditationStatus: "Pending", // Status set as string
            exists: true
        });

        // Emit event for accreditation request creation
        emit AccreditationRequestCreated(_equipmentId, msg.sender, _cab);
    }

    // Function for the international accreditation entity to make an accreditation decision
    function makeAccreditationDecision(uint256 _equipmentId, string memory decision) public {
        // Retrieve the accreditation request
        AccreditationRequest storage request = accreditationRequests[_equipmentId];

        // Ensure the request exists and is pending
        require(request.exists, "Accreditation request does not exist");
        require(keccak256(abi.encodePacked(request.accreditationStatus)) == keccak256(abi.encodePacked("Pending")), "Accreditation already decided");

        // Update the accreditation status
        require(keccak256(abi.encodePacked(decision)) == keccak256(abi.encodePacked("Approved")) ||
                keccak256(abi.encodePacked(decision)) == keccak256(abi.encodePacked("Denied")), 
                "Invalid decision value");

        request.accreditationStatus = decision;

        // Emit event for accreditation decision
        emit AccreditationDecisionMade(_equipmentId, decision);
    }

    // Function for a manufacturer to create a certification request
    function createCertificationRequest(uint256 _equipmentId, address _cab) public {
        // Ensure there is no existing certification request for the given equipment ID
        require(!certificationRequests[_equipmentId].exists, "Certification request already exists");

        // Ensure the accreditation request for the equipment ID exists and is approved
        require(accreditationRequests[_equipmentId].exists, "Accreditation request does not exist");
        require(keccak256(abi.encodePacked(accreditationRequests[_equipmentId].accreditationStatus)) == keccak256(abi.encodePacked("Approved")), "Accreditation not approved");

        // Create a new certification request
        certificationRequests[_equipmentId] = CertificationRequest({
            equipmentId: _equipmentId,
            manufacturer: msg.sender,
            cab: _cab,
            accreditationStatus: "Approved", // Use the existing approved accreditation status
            certificationStatus: "Pending", // Set as string
            exists: true
        });

        // Emit event for certification request creation
        emit CertificationRequestCreated(_equipmentId, msg.sender, _cab);
    }

    // Function for the certification authority to make a certification decision
    function makeCertificationDecision(uint256 _equipmentId, string memory decision) public {
        // Retrieve the certification request
        CertificationRequest storage request = certificationRequests[_equipmentId];

        // Ensure the request exists and the accreditation status is approved
        require(request.exists, "Certification request does not exist");
        require(keccak256(abi.encodePacked(request.accreditationStatus)) == keccak256(abi.encodePacked("Approved")), "Accreditation not approved");

        // Ensure the decision is either "Approved" or "Denied"
        require(keccak256(abi.encodePacked(decision)) == keccak256(abi.encodePacked("Approved")) ||
                keccak256(abi.encodePacked(decision)) == keccak256(abi.encodePacked("Denied")),
                "Invalid decision value");

        // Update the certification status
        request.certificationStatus = decision;

        // Emit event for certification decision
        emit CertificationDecisionMade(_equipmentId, decision);
    }

    // Function to get the accreditation request details
    function getAccreditationRequestDetails(uint256 _equipmentId) public view returns (uint256, address, address, string memory) {
        AccreditationRequest storage request = accreditationRequests[_equipmentId];
        require(request.exists, "Accreditation request does not exist");

        return (
            request.equipmentId,
            request.manufacturer,
            request.cab,
            request.accreditationStatus
        );
    }

    // Function to get the certification request details
    function getCertificationRequestDetails(uint256 _equipmentId) public view returns (uint256, address, address, string memory, string memory) {
        CertificationRequest storage request = certificationRequests[_equipmentId];
        require(request.exists, "Certification request does not exist");

        return (
            request.equipmentId,
            request.manufacturer,
            request.cab,
            request.accreditationStatus,
            request.certificationStatus
        );
    }
}
