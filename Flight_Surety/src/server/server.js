import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';
import express from 'express';
import regeneratorRuntime from "regenerator-runtime";


let config = Config['localhost'];
let web3 = new Web3(new Web3.providers.WebsocketProvider(config.url.replace('http', 'ws')));

//web3.eth.defaultAccount = web3.eth.accounts[0];
let flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
let oracles = [];

(async() => {
    let accounts = await web3.eth.getAccounts();
    let fee = await flightSuretyApp.methods.REGISTRATION_FEE().call();

    accounts.slice(5,10).forEach(async (oracleAccount) => {
        try {
            await flightSuretyApp.methods.registerOracle().send({from: oracleAccount, value: fee, gas: 3000000 });
            let indexesResult = await flightSuretyApp.methods.getMyIndexes().call({from: oracleAccount});
            oracles.push({address: oracleAccount, indexes: indexesResult});
        } catch(e) {
            console.log(e);
            console.log('Hello WOrld!')
        }
    })
})();

console.log("Registering Oracles ...");

(function() {
  var P = ["\\", "|", "/", "-"];
  var x = 0;
  return setInterval(function() {
    process.stdout.write("\r" + P[x++]);
    x &= 3;
  }, 250);
})();

setTimeout(() => {
  oracles.forEach(orcale => {
    console.log(`Oracle Address: ${orcale.address}, has indexes: ${orcale.indexes}`);
  })
  console.log("\nStart watching for event OracleRequest to submit responses")
}, 25000)

flightSuretyApp.events.OracleRequest({
    fromBlock: 0
  }, function (error, event) {
    if (error) {
        console.log(error);
    } else {
//        console.log(event);
        let randomStatusCode = Math.floor(Math.random() * 6)*10;
        let value = event.returnValues;
        console.log(`Got a new event with randome index: ${value.index} for flight: ${value.flight} and timestamp ${value.timestamp}`);

        oracles.forEach((oracle) => {
            oracle.indexes.forEach((index) => {
                flightSuretyApp.methods.submitOracleResponse(
                    index,
                    value.airline,
                    value.flight,
                    value.timestamp,
                    randomStatusCode
                    ).send( 
                        {from: oracle.address}
                    ).then(res => {
                    console.log(`--> Report from oracles(${oracle.address}).index(${index}) 👏🏽 accepted with status code ${randomStatusCode}`);
                }).catch(err => {
                    console.log(`--> Report from oracles(${oracle.address}).index(${index}) ❌ rejected with status code ${randomStatusCode}`);
                })
            })
        })
    }
});

const app = express();
app.get('/api', (req, res) => {
    res.send({
      message: 'An API for use with your Dapp!'
    })
})

export default app;


