### CONTRACT ADDRESS
**Supply Chain:** 0x0Ec5845DE6B892CF7b9eC9107C80557E3FE7c440

### LIBRARIES USED
**dotenv:** To store environment variables in a separate file and used them easily in the truffle config file.  
**truffle-hdwallet-provider:** To sign transactions for addresses.  

### VERSIONS 
Truffle v5.1.48 (core: 5.1.48)  
Solidity v0.5.16 (solc-js)  
Node v10.19.0  
Web3.js v1.2.1  

### USE OF DAPP
This Decentralized Application tracks the Supply Chain process of a fishing company.  
1. Fill the information on the forms with the required information.  
2. You can update the states of the item with the different buttons:  
**Harvest:** Adds the information to the contract.
**Process:** Marks the fish as processed, so the Distributor can start packing.  
**Pack:** Marks the Fish as packed and gets it ready for the retailer to start selling.  
**ForSale:** Once the Retailer has the product and verifies it's ready to sell marks the product as a ready to sell.  
**Buy** A buyer presses the button if wants to buy the product.  
**Ready For Pick Up:** Marks the item as ready for the buyer to come and pick it up on the store.  
**Item Picked Up:** Marks the item as picked up by the buyer.  
**Purchased:** Marks the item as gone (Finished the process).  

At the bottom there is a Transaction history where we can see the changes on the contract as well as the TX hashes for authenticity and confirmation.  

