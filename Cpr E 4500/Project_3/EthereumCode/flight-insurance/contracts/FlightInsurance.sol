// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract FlightInsurance {

    address payable public insuranceProvider;
    uint public constant PREMIUM   = 0.01 ether;
    uint public constant INDEMNITY = 0.02 ether;

    struct Policy {
        string passengerName;
        address payable passengerAddress;
        string flightNumber;
        string flightDate;
        string departureCity;
        string destinationCity;
        string status;
        bool exists;
    }

    mapping(address => Policy) private policies;
    address[] private policyHolders;

    modifier onlyProvider() {
        require(msg.sender == insuranceProvider, "Only insurance provider can call this.");
        _;
    }

    constructor() {
        insuranceProvider = payable(msg.sender);
    }

    function view_available_policy() public pure returns (string memory) {
        return "Premium: 0.01 ETH | Indemnity: 0.02 ETH | Coverage: Hail, Flood";
    }

    function purchase_policy(
        string memory _name,
        string memory _flightNumber,
        string memory _flightDate,
        string memory _departureCity,
        string memory _destinationCity
    ) public payable {
        require(msg.value == PREMIUM, "Must send exactly 0.01 ETH.");
        require(!policies[msg.sender].exists, "Policy already purchased.");

        policies[msg.sender] = Policy({
            passengerName:    _name,
            passengerAddress: payable(msg.sender),
            flightNumber:     _flightNumber,
            flightDate:       _flightDate,
            departureCity:    _departureCity,
            destinationCity:  _destinationCity,
            status:           "purchased",
            exists:           true
        });

        policyHolders.push(msg.sender);
        insuranceProvider.transfer(msg.value);
    }

    function view_purchased_policy() public view returns (
        string memory, string memory, string memory,
        string memory, string memory, string memory
    ) {
        require(policies[msg.sender].exists, "No policy found.");
        Policy memory p = policies[msg.sender];
        return (p.passengerName, p.flightNumber, p.flightDate,
                p.departureCity, p.destinationCity, p.status);
    }

    function view_balance() public view returns (uint) {
        return msg.sender.balance;
    }

    function view_all_policies() public view onlyProvider returns (
        address[] memory,
        string[] memory,
        string[] memory,
        string[] memory,
        string[] memory,
        string[] memory,
        string[] memory
    ) {
        uint count = policyHolders.length;
        address[] memory addrs        = new address[](count);
        string[]  memory names        = new string[](count);
        string[]  memory flights      = new string[](count);
        string[]  memory dates        = new string[](count);
        string[]  memory departures   = new string[](count);
        string[]  memory destinations = new string[](count);
        string[]  memory statuses     = new string[](count);

        for (uint i = 0; i < count; i++) {
            Policy memory p = policies[policyHolders[i]];
            addrs[i]        = policyHolders[i];
            names[i]        = p.passengerName;
            flights[i]      = p.flightNumber;
            dates[i]        = p.flightDate;
            departures[i]   = p.departureCity;
            destinations[i] = p.destinationCity;
            statuses[i]     = p.status;
        }

        return (addrs, names, flights, dates, departures, destinations, statuses);
    }

    function pay_indemnity(address payable passenger) public payable onlyProvider returns (bool) {
        require(policies[passenger].exists, "No policy for this address.");
        require(
            keccak256(bytes(policies[passenger].status)) == keccak256(bytes("purchased")),
            "Already claimed."
        );
        require(msg.value == INDEMNITY, "Must send exactly 0.02 ETH.");

        policies[passenger].status = "claimed";
        passenger.transfer(INDEMNITY);
        return true;
    }
}
