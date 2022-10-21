
var FlightSuretyApp = artifacts.require('FlightSuretyApp');
var FlightSuretyData = artifacts.require('FlightSuretyData');

contract('Flight Surety Tests', function (accounts) {

    const owner = accounts[0];
    const firstAirline = accounts[5];
    
    console.log("ganache-cli accounts used here...")
    console.log("Contract Owner: accounts[0] ", accounts[0])
    console.log("First Airline: accounts[5] ", firstAirline);  

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {
    const flightSuretyData = await FlightSuretyData.deployed();
    // Get operating status
    let status = await flightSuretyData.isOperational()
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

    const flightSurety = await FlightSuretyData.deployed()
      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await flightSurety.setOperatingStatus(false, { from: firstAirline });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

    const flightSurety = await FlightSuretyData.deployed()
      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await flightSurety.setOperatingStatus(false);
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

    const flightSurety = await FlightSuretyData.deployed()
      await flightSurety.setOperatingStatus(false);

      let reverted = false;
      try 
      {
          await flightSurety.setTestingMode();
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await flightSurety.setOperatingStatus(true);

  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    const flightSurety = await FlightSuretyApp.deployed()
    // ARRANGE
    let newAirline = accounts[2];
    let reverted = false;
    // ACT
    try {
        await flightSurety.registerAirline(newAirline, {from: firstAirline});
    }
    catch(e) {
        reverted = true;
    }

    // ASSERT
    assert.equal(reverted, true, "Airline should not be able to register another airline if it hasn't provided funding");

  });

  it('(airline) Funded Airline Registers correctly whithout multiparty consensus', async () => {
    
    const flightSuretyData = await FlightSuretyData.deployed()
    const flightSurety = await FlightSuretyApp.deployed()

    // ARRANGE
    let newAirline = accounts[2];
    let reverted = false;

    // ACT
    try {
        await flightSuretyData.fund(firstAirline, {from: firstAirline, value: web3.utils.toWei('11', "ether")});
        await flightSurety.registerAirline(newAirline, {from: firstAirline});
    }
    catch(e) {
        reverted = true;
    }

    // ASSERT
    assert.equal(reverted, false, "Existing Airline Failed Registering new Airline");
  });
 
  it('(airline) Funded Airline Registers correctly whith multiparty consensus', async () => {

    const flightSuretyData = await FlightSuretyData.deployed()
    const flightSurety = await FlightSuretyApp.deployed()

    let airlines = [accounts[1], accounts[3], accounts[4]];
    let testAirline = accounts[6];

    //Register and Fund Minimum Airlines to activate multiparty
    for(let i = 0; i < airlines.length; i++) {
        await flightSurety.registerAirline(airlines[i], {from: firstAirline});
        await flightSuretyData.fund(airlines[i], {from: airlines[i], value: web3.utils.toWei('11', "ether")});
    }

    let test1 = false;
    let test2 = false;

    //Register Airline with Multiparty test 1
    try {
        await flightSurety.registerAirline(testAirline, {from: firstAirline});
    }
    catch(e) {
        test1 = true;
    }

    //Register Airline with Multiparty test 2
    try {
        await flightSuretyData.vote(testAirline, {from: accounts[1]});
        await flightSuretyData.vote(testAirline, {from: accounts[4]});
        await flightSuretyData.vote(testAirline, {from: accounts[3]});
    }
    catch(e) {
        test2 = true;
    }

    //ASSERT
    assert.equal(test1, true, "RegisterAirline should not have worked");
    assert.equal(test2, false, "RegisterAirline should have worked");
  });

  
  it('(flight) Comparing FLight KEYS', async () => {

    const flightSuretyData = await FlightSuretyData.deployed()
    const flightSurety = await FlightSuretyApp.deployed()
    let departure = Math.floor(new Date(2019, 3, 1, 22, 30, 0, 0) / 1000);
    let key1 = await flightSurety.getFlightKeyExternal(firstAirline,'BP209', departure);
    let key2 = await flightSurety.getFlightKeyExternal(firstAirline,'BP209', departure);

    assert.equal(key1,key2, "Different keys with same values");
  });
});
