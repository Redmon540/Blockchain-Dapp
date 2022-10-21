pragma solidity >=0.4.21 <0.6.1;
import "./ERC721Mintable.sol";
import 'openzeppelin-solidity/contracts/drafts/Counters.sol';
import {Pairing} from "./verifier.sol";

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x1936c240636390dc823e3a728e94b208eb53c6756d81da57ec3425e05d43ac10), uint256(0x2d70ff78e8216bf29d58923a686d9738278b8ce2fd822e197c85b09286d15566));
        vk.beta = Pairing.G2Point([uint256(0x29c13ecb6f33dbc4b3b8a02e2e255511ce4c26a8a2f299efcc94caf2de4fce00), uint256(0x2b4daf047abe2e7f0b311118c1b963b63695dc0d769cea78849604434de055bf)], [uint256(0x25ea0d7e2b29de431b86a943db30dbf4d98f68df9ca8a9628d14d1591e817d90), uint256(0x1da9020008df7f549751f8a251af3b2dc4a2ad3e0870de54acaedd9fc1b47e17)]);
        vk.gamma = Pairing.G2Point([uint256(0x00e83c788c2878d1d5eba3ed49b0d81e4c0487dedc3e4d1c2baab5833785b62f), uint256(0x011016e22ae045444f50fb80f246ec486c7e02af09132cd38c4fcf484983e4f2)], [uint256(0x132a90a3b0d369ccd66e2a5ba04a935e44d8ad5dca93a76bba592a578130a911), uint256(0x05eb89e741ed5b5d611cebf92d1ed02cd6f3311089f0d400df7d9ced5a48fd41)]);
        vk.delta = Pairing.G2Point([uint256(0x0c3b60f59d3bd50328a04c0ff6d979199685d0526f89f6ac29d6174ce24707a2), uint256(0x065f6a3323a2abffd621fc263f348eb914904b68d5897729ae34a6b9d33f0852)], [uint256(0x12e0f3721230a0f38f6c9913048d5230fd2615ef3ff7f6ee4b20dfe0bdea1a86), uint256(0x26e7ebce2b44efef6b6315938e33f0a8ecc82dbad635c9efa681ed85bbb59982)]);
        vk.gamma_abc = new Pairing.G1Point[](3);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1ef8d5d70234aa3e3d8fc4e3f1ca01c703182580b581106798f05b35fd5082c0), uint256(0x2e468046d4ae35138e2032224925d5389712e5ca5e68f4d9c1e1858e7d65602d));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x0cefae0e3fa6aa25a4485ab7b21d32794d3431a4e4a5ca82ea427b831534c2c9), uint256(0x23e3d2035b70884e547638b111870f5957f58ad8068f7a21470164ad361e1e88));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x030ffe78ec3de150e8688db619bde78e21e894754e6be5ed83742677628b24bc), uint256(0x053392f88cfa9092dfbc0bd199d8159e56207779473c24fc601eff91bcd345ca));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c, uint[2] memory input
        ) public view returns (bool r) {
        Proof memory proof;
        proof.a = Pairing.G1Point(a[0], a[1]);
        proof.b = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.c = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](2);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}

// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is CustomERC721Token {

Verifier verifier = new Verifier();
Counters.Counter private _currentIndex;

// TODO define a solutions struct that can hold an index & an address
struct solution {
    uint256 index;
    address solutionAddress;   
    bool passed; 
}

// TODO define a mapping to store unique solutions submitted
mapping(bytes32 => solution) solutions;

// TODO Create an event to emit when a solution is added
event SolutionAdded(uint256 index, address solutionAddress);

// TODO Create a function to add the solutions to the array and emit the event
function addSolution(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[2] memory input) public{
    bytes32 hash = keccak256(abi.encode(input[0], input[1]));
    require(solutions[hash].solutionAddress == address(0));
    require(verifier.verifyTx(a,b,c,input), "Solution not verified");
    
    solutions[hash] = solution(_currentIndex.current(), msg.sender, false);
    emit SolutionAdded(_currentIndex.current(), msg.sender);
    _currentIndex.increment();
}


// TODO Create a function to mint new NFT only after the solution has been verified
//  - make sure the solution is unique (has not been used before)
//  - make sure you handle metadata as well as tokenSuplly
function mintNFT(uint[2] memory input, address to) public{
    bytes32 hash = keccak256(abi.encode(input[0],input[1]));
    require(solutions[hash].solutionAddress != address(0));
    require(solutions[hash].passed == false);
    require(solutions[hash].solutionAddress == msg.sender);

    super.mint(to, solutions[hash].index);
    solutions[hash].passed = true;
}
}
  


























