/*##############################################
 *# SIMPLE ETHEREUM TRANSACTION WITH GANACHE   #
 *##############################################*/

//Config
const Web3 = require('web3')
const web3 = new Web3('HTTP://127.0.0.1:8545')

//Setting Wallet accounts
let sendingAddress = '0xdCc443e2f4B8379E123c4aE7a21C42e04739DE2E'
let senderPrivateKey = '0xb9fe83e82957e2aa98d8217ba6adc29922d4f7361e0ec372fe2c87bd3065b0cd'
let recievingAddress = '0xaB9454e67AA3125EdC6F7E3273A8f68215bdB65E'

async function sendTransaction(sender, privateKey, reciever){

    //Getting Initial balance
    let senderBalance = await web3.eth.getBalance(sender)
    let recieverBalance = await web3.eth.getBalance(reciever)
    
    console.log(`Starting sender Balance: ${senderBalance}`)
    console.log(`Starting reciever Balance: ${recieverBalance}`)
    console.log('------------------------------------------------')
    console.log('Building Transaction...')
    console.log('------------------------------------------------')

    //Creating Transaction
    let rawTransaction = {
        from: sender,
        to: reciever,
        gasPrice: 20000000,
        gasLimit: 30000,
        value: "1000000000000000000",
        data: ""
    }

    //Sign TX
    let transaction = await web3.eth.accounts.signTransaction(rawTransaction,privateKey)
    //Send TX to Network
    web3.eth.sendSignedTransaction(transaction.rawTransaction)
        .then(reciept => console.log("Transaction receipt: ", reciept))
        .catch(err => console.log(err))

    //Getting Final balance
    let finalSenderBalance = await web3.eth.getBalance(sender)
    let finalRecieverBalance = await web3.eth.getBalance(reciever)
    
    console.log(`Final sender Balance: ${finalSenderBalance}`)
    console.log(`Final reciever Balance: ${finalRecieverBalance}`)
}

//Run Transaction
sendTransaction(sendingAddress, senderPrivateKey, recievingAddress)



