pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;
    using SafeMath for uint16;
    using SafeMath for uint;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    
    struct Airline {
        bool registered;
        bool funded;
        bytes32[] flightKeys;
        Votes votes;
    }

    struct Votes{
        uint256 counter;
        mapping(address => bool) voters;
    }

    struct Insurance {
        address airline;
        bytes32 flightKey;
        uint16 numberInsurees;
        Insuree[] insuree;
    }

    struct Insuree {
        uint value;
        address buyer;
    }
     

    mapping(address => Airline) private airlines;
    mapping(address => uint256) private insureesWallet;
    mapping(uint256 => address) public registeredAirlinesAddress;
    mapping(bytes32 => Insurance) private insurances;

    uint256 private registeredAirlines;
    uint256 private fundedAirlines;
    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/
    
    event AirlineRegistered(address airlineAddress, bool registered);
    event AirlineFunded(address airlineAddress);
    event VoteAdded(address airlineAddress);
    event InsuranceAdded(bytes32 flightKey, address buyerAddress);
    event CreditAddedToInsurees(bytes32 flightKey, address airlineAddress);

    /**
    /* @dev Constructor
    /* The deploying account becomes contractOwner
    **/
   
    constructor (address airlineAddress) public {
        contractOwner = msg.sender;
        //Registering First Airline
        airlines[airlineAddress] = Airline({
            registered: true,
            funded: false,
            flightKeys: new bytes32[](0),
            votes: Votes(0)
        });

        registeredAirlines = registeredAirlines.add(1);
        registeredAirlinesAddress[registeredAirlines] = airlineAddress;
        emit AirlineRegistered(airlineAddress, airlines[airlineAddress].registered);
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    **/
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireAirlineRegistered(address airlineAddress)
    {
        require(airlines[airlineAddress].registered == true, "Caller is not contract owner");
        _;
    }

    modifier requireAirlineFunded(address airlineAddress)
    {
        require(airlines[airlineAddress].funded == true, "Caller is not contract owner");
        _;
    }
    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public
                            view
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    // @dev Add an airline to the registration queue
    // Can only be called from FlightSuretyApp contract   
    function registerAirline(address airlineAddress, bool submitToVote) external {
        //Checking Voting requirements
        if(submitToVote){
            require(airlines[airlineAddress].registered != true,"Airline already registered");
            emit VoteAdded(airlineAddress);
            _updateVotingProcess(airlineAddress, msg.sender);
        } else {
            require(airlines[airlineAddress].registered != true,"Airline already registered");
            airlines[airlineAddress].registered = true;
            registeredAirlines = registeredAirlines.add(1);
            registeredAirlinesAddress[registeredAirlines] = airlineAddress;
            emit AirlineRegistered(airlineAddress, airlines[airlineAddress].registered);
        }
    }

    // @dev Updates the Votes from an airline in order to be registered with 
    //      Multiparty Consensus  

    //Give a vote to an Airline
    function vote(address airlineAddress) external 
    {
        require(fundedAirlines >= 4);
        _updateVotingProcess(airlineAddress,msg.sender);
    }

    //Update voting process 
    function _updateVotingProcess(address airlineAddress, address votingAirlineAddress) internal 
    requireIsOperational
    requireAirlineFunded(votingAirlineAddress)
    {
        uint256 min_votes = fundedAirlines.div(2);
        bool airlineVote = airlines[airlineAddress].votes.voters[votingAirlineAddress];

        //Add vote
        if(!airlineVote){
            airlines[airlineAddress].votes.voters[votingAirlineAddress] = true;
            airlines[airlineAddress].votes.counter = airlines[airlineAddress].votes.counter.add(1);   
            emit VoteAdded(airlineAddress);
        }
      
        //Register Airline
        if(airlines[airlineAddress].votes.counter >= min_votes) {
            airlines[airlineAddress].registered = true;
            registeredAirlines = registeredAirlines.add(1);
            registeredAirlinesAddress[registeredAirlines] = airlineAddress;
            emit AirlineRegistered(airlineAddress, airlines[airlineAddress].registered);
        }
    }

   // @dev Add registered flight to airline with key 
    function addFlightKeyToAirline(address airlineAddress, bytes32 flightKey)
    external
    {
        airlines[airlineAddress].flightKeys.push(flightKey);
    }   
   
   // @dev Buy insurance for a flight   
    function buy (bytes32 flight, address airlineAddress) external payable
    {
        require(msg.value <= 1 ether);
        require(msg.value >= 0.1 ether);
        //Check if Insurance for flight is created
        if(insurances[flight].flightKey != flight){
            insurances[flight].airline = airlineAddress;
            insurances[flight].flightKey = flight;
        }
             
        _addNewInsuree(flight,msg.sender,msg.value);
        emit InsuranceAdded(flight,msg.sender);
    }

    // @dev Internal function to add Insuree to an Insurance
    function _addNewInsuree(bytes32 flight, address buyerAddress, uint value) internal
    {
        Insuree memory buyer;
        buyer.value = value;
        buyer.buyer = buyerAddress;
        _updateWallet(buyerAddress, value);
        insurances[flight].insuree.push(buyer);
        insurances[flight].numberInsurees.add(1);
    }

    // @dev Update Insuree Wallet
    function _updateWallet(address insureeAddress, uint value) internal
    {
        insureesWallet[insureeAddress] = insureesWallet[insureeAddress].add(value);
    }

    // @dev Credits payouts to insurees
    function creditInsurees(bytes32 flight, address airlineAddress) external
    {
        uint counter = insurances[flight].numberInsurees;
        for(uint i = 0; i < counter; i++){ 
            uint value = insurances[flight].insuree[i].value;
            uint credit = insurances[flight].insuree[i].value.add(insurances[flight].insuree[i].value.div(2));
            value = value.add(credit);
            _updateWallet(insurances[flight].insuree[i].buyer, credit);
        }
        emit CreditAddedToInsurees(flight,airlineAddress);
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree wallet
     *
    */
    function withdraw
                            (
                            )
                            external
                            payable
    {
        require(insureesWallet[msg.sender] >= 0.1 ether, "Not enough found to withdraw");
        msg.sender.transfer(insureesWallet[msg.sender]); 
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    **/   
    function fund(address airlineAddress) public payable 
    requireAirlineRegistered(airlineAddress) 
    requireIsOperational
    {
        require(msg.sender == airlineAddress, "Airline can't be funded by someone else");
        require(msg.value >= 10 ether, "Not enough ether send");
        if(airlines[airlineAddress].funded != true){
            airlines[airlineAddress].funded = true;
            fundedAirlines = fundedAirlines.add(1);
        }
        emit AirlineFunded(airlineAddress);
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    //Get Airline Address by ID
    function getAirlineAddressId(uint256 id) public view returns(address) {
       return  registeredAirlinesAddress[id]; 
    }

    function airlineFunded(address airlineAddress) public view returns(bool) {
        if(airlines[airlineAddress].funded){
            return true;
        }
        return false;
    }

    function getFundedAirlines() public view returns(uint256){
        return fundedAirlines;
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund(msg.sender);
    }


}

