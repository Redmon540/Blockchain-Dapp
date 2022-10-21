pragma solidity >=0.4.22 <0.7.0;

//Importing role files
import "../accessControl/FisherMan.sol";
import "../accessControl/RestaurantOwner.sol";
import "../accessControl/Distributor.sol";
import "../accessControl/Retailer.sol";

contract SupplyChain is FisherMan,RestaurantOwner,Distributor,Retailer {

    address payable owner;
    
    // Variable for Universal Product Code
    uint upc;

    // Variable for Stock Keeping Unit
    uint sku;

    // Mapping the UPC to an Item
    mapping (uint => Item) items;

    // Maps UPC to an array of TxHash, tracks its journey through the supply chain.
    mapping (uint => string[]) itemsHistory;


    //Possible states of the product
    enum State {
        Harvested, //0
        Processed, //1
        Packed, //2
        ForSale, //3
        Sold, //4
        ReadyPickUp, //5
        PickedUp, //6
        Purchased //7
    }

    //Define struct Item, representing the type of fish.
    struct Item {
        uint sku;
        uint upc;
        address payable ownerID;
        address payable originFisherManID;
        string originFisherManName;
        string originFisherManInfo;
        string itemCaughtLatitude;
        string itemCaughtLongitude;
        uint productID;
        string productNotes;
        uint productPrice;
        State itemState;
        address distributorID;
        address retailerID;
        address payable buyerID;
    }

    //Defining events with 'upc' as input argument.
    event Harvested(uint upc);
    event Processed(uint upc);
    event Packed(uint upc);
    event ForSale(uint upc);
    event Sold(uint upc);
    event ReadyPickUp(uint upc);
    event PickedUp(uint upc);
    event Purchased(uint upc);

    //Check if ms.sender == owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //Check if the paid amount is sufficient.
    modifier paidEnough(uint _price) {
        require(msg.value >= _price);
        _;
    }

    //Check price and refunds remaining balance.
    modifier checkValue(uint _upc, address payable buyerID) {
        _;
        uint _price = items[_upc].productPrice;
        uint amountToReturn = msg.value - _price;
        buyerID.transfer(amountToReturn);
    }

    //Check if an item.state of a upc is Harvested.
    modifier harvested(uint _upc) {
        require(items[_upc].itemState == State.Harvested);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Processed
    modifier processed(uint _upc) {
        require(items[_upc].itemState == State.Processed);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Packed
    modifier packed(uint _upc) {
        require(items[_upc].itemState == State.Packed);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is ForSale
    modifier forSale(uint _upc) {
        require(items[_upc].itemState == State.ForSale);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Sold
    modifier sold(uint _upc) {
        require(items[_upc].itemState == State.Sold);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Shipped
    modifier readyPickUp(uint _upc) {
        require(items[_upc].itemState == State.ReadyPickUp);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Received
    modifier pickedUp(uint _upc) {
        require(items[_upc].itemState == State.PickedUp);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Purchased
    modifier purchased(uint _upc) {
        require(items[_upc].itemState == State.Purchased);
        _;
    }

    // In the constructor set 'owner' to the address that instantiated the contract
    // and set 'sku' to 1
    // and set 'upc' to 1
    constructor() public payable {
        owner = msg.sender;
        sku = 1;
        upc = 1;
    }

    // Define a function 'kill' if required
    function kill() public {
        if (msg.sender == owner) {
          selfdestruct(owner);
        }
    }

    // Define a function 'harvestItem' that allows a fisherMan to mark an item 'Harvested'
    function harvestItem(uint _upc, address payable _originFisherManID, string memory _originFisherManName, string memory _originFisherManInfo, string memory _itemCaughtLatitude, string memory _itemCaughtLongitude, string memory _productNotes) public  
    //Call modifier to verify caller
    onlyFisher()
    {
        // Add the new item as part of Harvest
        items[_upc].upc = _upc;
        items[_upc].sku = sku;
        items[_upc].ownerID = owner;
        items[_upc].originFisherManID = _originFisherManID;
        items[_upc].originFisherManName = _originFisherManName; 
        items[_upc].originFisherManInfo = _originFisherManInfo;
        items[_upc].itemCaughtLatitude = _itemCaughtLatitude;
        items[_upc].itemCaughtLongitude = _itemCaughtLongitude;
        items[_upc].productNotes = _productNotes;
        //add Harvested State
        items[_upc].itemState = State.Harvested;
        // Increment sku
        sku = sku + 1;
        // Emit the appropriate event
        emit Harvested(_upc);
    }

    // Define a function 'processItem' that allows a fisherMan to mark an item 'Processed'
    function processItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    harvested(_upc) 
    // Call modifier to verify caller of this function
    onlyFisher()
    {
    // Update the appropriate fields
    items[_upc].itemState = State.Processed;
    // Emit the appropriate event
    emit Processed(_upc);
    }

    // Define a function 'packItem' that allows a fisherMan to mark an item 'Packed'
    function packItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    processed(_upc)
    // Call modifier to verify caller of this function
    onlyDistributor()
    {
    // Update the appropriate fields
    items[_upc].itemState = State.Packed;
    items[_upc].distributorID = msg.sender;
    // Emit the appropriate event
    emit Packed(_upc);
    }

    // Define a function 'sellItem' that allows a fisherMan to mark an item 'ForSale'
    function sellItem(uint _upc, uint _price) public 
    // Call modifier to check if upc has passed previous supply chain stage
    packed(_upc)
    // Call modifier to verify caller of this function
    onlyRetailer()
    {
    // Update the appropriate fields
    items[_upc].itemState = State.ForSale;
    items[_upc].productPrice = _price;
    items[_upc].retailerID = msg.sender;
    // Emit the appropriate event
    emit ForSale(_upc);
    }

    // Define a function 'buyItem' that allows the fisherMan to mark an item 'Sold'
    // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
    // and any excess ether sent is refunded back to the buyer
    function buyItem(uint _upc) public payable 
    // Call modifier to check if upc has passed previous supply chain stage
    forSale(_upc)
    // Call modifier to verify caller of this function
    onlyBuyer()
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice)
    // Call modifer to send any excess ether back to buyer
    checkValue(_upc, msg.sender)
    {

    // Update the appropriate fields - ownerID, itemState
    items[_upc].buyerID = msg.sender;
    items[_upc].ownerID = items[_upc].buyerID;
    items[_upc].itemState = State.Sold;
    // Transfer money to fisherMan
    items[_upc].originFisherManID.transfer(items[_upc].productPrice);
    // emit the appropriate event
    emit Sold(_upc);
    }

    // Define a function 'readyPickUp' that allows the fisherMan to mark an item as ready to be picked up
    // Use the above modifers to check if the item is sold
    function readyToPickUp(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    sold(_upc)
    // Call modifier to verify caller of this function
    onlyRetailer()
    {
    // Update the appropriate fields
    items[_upc].itemState = State.ReadyPickUp;
    // Emit the appropriate event
    emit ReadyPickUp(_upc);
    }

    // Define a function 'pickedUp' that allows the fisherMan to mark an item 'PickedUp'
    // Use the above modifiers to check if the item is shipped
    function itemPickedUp(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    readyPickUp(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    onlyRetailer()
    {
    // Update the state
    items[_upc].itemState =  State.PickedUp;
    // Emit the appropriate event
    emit PickedUp(_upc);
    }

    // Define a function 'purchaseItem' that allows the fisherMan to mark an item 'Purchased'
    // Use the above modifiers to check if the item is received
    function purchaseItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    pickedUp(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    onlyRetailer()
    {
    // Update the appropriate fields - itemState
    items[_upc].itemState = State.Purchased;
    // Emit the appropriate event
    emit Purchased(_upc);
    }

    // Define a function 'fetchItemBufferOne' that fetches the data
    function fetchItemBufferOne(uint _upc) public view returns 
    (
    uint    itemSKU,
    uint    itemUPC,
    address ownerID,
    address payable originFisherManID,
    string memory originFisherManName,
    string memory originFisherManInfo,
    string memory itemCaughtLatitude,
    string memory itemCaughtLongitude
    ) 
    {
    // Assign values to the 8 parameters
    itemSKU = items[_upc].sku;
    itemUPC = items[_upc].upc;
    ownerID = items[_upc].ownerID;
    originFisherManID = items[_upc].originFisherManID;
    originFisherManName = items[_upc].originFisherManName;
    originFisherManInfo = items[_upc].originFisherManInfo;
    itemCaughtLatitude = items[_upc].itemCaughtLatitude;
    itemCaughtLongitude = items[_upc].itemCaughtLongitude;

    return 
    (
    itemSKU,
    itemUPC,
    ownerID,
    originFisherManID,
    originFisherManName,
    originFisherManInfo,
    itemCaughtLatitude,
    itemCaughtLongitude
    );
    }

    // Define a function 'fetchItemBufferTwo' that fetches the data
    function fetchItemBufferTwo(uint _upc) public view returns 
    (
    uint    itemSKU,
    uint    itemUPC,
    uint    productID,
    string memory productNotes,
    uint    productPrice,
    State   itemState,
    address buyerID,
    address distributorID,
    address retailerID
    ) 
    {
    // Assign values to the 9 parameters
    itemSKU = items[_upc].sku;
    itemUPC = items[_upc].upc;
    productID = items[_upc].sku + items[_upc].upc;
    productNotes = items[_upc].productNotes;
    productPrice = items[_upc].productPrice;
    itemState = items[_upc].itemState;
    buyerID = items[_upc].buyerID;
    distributorID = items[_upc].distributorID;
    retailerID = items[_upc].retailerID;

    return 
    (
    itemSKU,
    itemUPC,
    productID,
    productNotes,
    productPrice,
    itemState,
    buyerID,
    distributorID,
    retailerID
    );
    }
}

