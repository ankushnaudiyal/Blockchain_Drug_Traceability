// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DrugTraceability {
    // Structure to store drug details
    struct Drug {
        string batchId;
        string name;
        address manufacturer;
        address distributor;
        address retailer;
        bool isAuthentic;
        string currentOwner;
    }

    // Mapping to store drug information by batch ID
    mapping(string => Drug) public drugs;

    // Events for logging activities
    event DrugManufactured(string batchId, string name, address manufacturer);
    event DrugDistributed(string batchId, address distributor);
    event DrugRetailerReceived(string batchId, address retailer);
    event DrugVerified(string batchId, string currentOwner);

    // Function to register a new drug by the manufacturer
    function manufactureDrug(string memory _batchId, string memory _name) public {
        require(bytes(_batchId).length > 0, "Batch ID cannot be empty");
        require(bytes(_name).length > 0, "Drug name cannot be empty");

        drugs[_batchId] = Drug({
            batchId: _batchId,
            name: _name,
            manufacturer: msg.sender,
            distributor: address(0),
            retailer: address(0),
            isAuthentic: false,
            currentOwner: "Manufacturer"
        });

        emit DrugManufactured(_batchId, _name, msg.sender);
    }

    // Function to record distribution of the drug
    function distributeDrug(string memory _batchId, address _distributor) public {
        Drug storage drug = drugs[_batchId];
        require(msg.sender == drug.manufacturer, "Only the manufacturer can distribute");
        require(_distributor != address(0), "Invalid distributor address");

        drug.distributor = _distributor;
        drug.currentOwner = "Distributor";

        emit DrugDistributed(_batchId, _distributor);
    }

    // Function to record when the retailer receives the drug
    function receiveByRetailer(string memory _batchId, address _retailer) public {
        Drug storage drug = drugs[_batchId];
        require(msg.sender == drug.distributor, "Only the distributor can update retailer");
        require(_retailer != address(0), "Invalid retailer address");

        drug.retailer = _retailer;
        drug.currentOwner = "Retailer";

        emit DrugRetailerReceived(_batchId, _retailer);
    }

    // Function to verify the authenticity of a drug
    function verifyDrug(string memory _batchId) public view returns (bool) {
        Drug memory drug = drugs[_batchId];
        require(bytes(drug.batchId).length > 0, "Drug does not exist");
        return drug.isAuthentic;
    }

    // Function to mark a drug as authentic (usually done at the end of the supply chain)
    function markAuthentic(string memory _batchId) public {
        Drug storage drug = drugs[_batchId];
        require(msg.sender == drug.retailer, "Only the retailer can mark as authentic");

        drug.isAuthentic = true;
        drug.currentOwner = "Verified by Retailer";

        emit DrugVerified(_batchId, drug.currentOwner);
    }
}
