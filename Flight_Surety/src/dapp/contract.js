import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import FlightSuretyData from '../../build/contracts/FlightSuretyData.json';
import Config from './config.json';
import Web3 from 'web3';

export default class Contract {
    constructor(network, callback) {

        let config = Config[network];
        this.web3 = new Web3(new Web3.providers.HttpProvider(config.url));
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
        this.flightSuretyData = new this.web3.eth.Contract(FlightSuretyData.abi, config.dataAddress);
        this.owner = null;
        this.airlines = [];
        this.passenger = null;
        this.flights = new Map();
        this.initialize(callback);
    }

    async initialize(callback) {
        let accts = await this.web3.eth.getAccounts();
           
        this.owner = accts[0];
        this.passenger = accts[0];

        const flights = ['BP209', 'AM560', 'LM324', 'MB098'];

        let firstAirline = accts[5];
        let airlinesAddress = accts.slice(1,10);

        //Fund First Airline 
        try {
            await this.flightSuretyData.methods.fund(firstAirline)
                .send({
                    from: firstAirline,
                    value: this.web3.utils.toWei('10', 'ether'),
                    gas: 1500000
                });
            console.log(`First Airline ${firstAirline} funded correctly`);
        } catch(e) {
            console.log(e);
            console.log(`Error funding Airline: ${firstAirline}`);
        }

        //Register Airlines
        for(let i = 0; i < 3; i++) {
            try {
                await this.flightSuretyApp.methods.registerAirline(airlinesAddress[i]).send({from: firstAirline});
                console.log(`Airline ${airlinesAddress[i]}, registered successfully by: ${firstAirline}`);
            } catch (e) {
                console.log(e)
                console.log(`Error registering Airline with address: ${airlinesAddress[i]}`)
            }
        }

        //Register Flights for FirstAirline
        for(let i=0; i < flights.length; i++){
            try {
                let departure = Math.floor(new Date(2019, 3, 1, 22, 30, 0, 0) / 1000);
                this.flights.set(flights[i], {
                    airlineAddress: firstAirline,
                    name: flights[i],
                    departure: departure
                });
                let obj = this.flights.get(flights[i]);
                let key = await this.flightSuretyApp.methods.getFlightKeyExternal(obj.airlineAddress, obj.name, obj.departure);
                await this.flightSuretyApp.methods.registerFlight(obj.departure, obj.airlineAddress, obj.name);
                console.log('Initial Flights successfully registered for firstAirline.');
            } catch(e) {
                console.log(e);
                console.log('Error Initi First Airline Flights.');
            }
        }

        //Passanger Buys Insurance
        let obj = this.flights.get('BP209');
        try {
            await this.flightSuretyApp.methods.buy(obj.name, obj.airlineAddress, obj.departure)
            .send({from: this.passenger, value: this.web3.utils.toWei('0.2', 'ether')});
            console.log('Insurance successfully bought')
        } catch(e) {
            console.log(e)
            console.log('Error buying insurance')
        }
        callback();
    }

    isOperational(callback) {
       let self = this;
       self.flightSuretyData.methods
            .isOperational()
            .call({ from: self.owner}, callback);
    }

    fetchFlightStatus(flight, callback) {
        let self = this;
        console.log(self.flights)
        let obj = self.flights.get(flight)
        let payload = {
            airline: obj.airlineAddress,
            flight: obj.name,
            timestamp: Math.floor(Date.now() / 1000)
        } 
        self.flightSuretyApp.methods
            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
            .send({ from: self.owner}, (error, result) => {
                callback(error, payload);
            });
    }

    async buyInsurance(flight, callback) {
    let self = this;
    let obj = self.flights.get(flight)

    await self.flightSuretyApp.methods.buy(obj.name, obj.airlineAddress, obj.departure)
        .send({from: self.passenger, value: self.web3.utils.toWei('0.2', 'ether')}, (error, result) => {
            callback(error, obj);
        });
    }

    withDraw(callback) {
    let self = this;
    self.flightSuretyData.methods.withdraw().call({from: self.passenger}, callback);
    }
}
