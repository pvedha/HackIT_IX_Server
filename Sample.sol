pragma solidity ^0.4.11;
contract Sample {

    enum contractState { Created, InProgress, Completed }
    enum beneficiaryState { Initiated, ReadyForReview, Completed, Distributed }

    uint public price;
    mapping (address => uint) balance;

    bool public peerReviewNeeded;
    bool public documentProofNeeded;
    uint public totalAmount;
    uint public bonusAmount;
    uint public amountPerHead;
    contractState public status;
    struct beneficiary {
        address myAddress;
        address myPeer;
        bool authorized;
        beneficiaryState status;
        uint selfData; // delegateWeight is accumulated by delegation
        bool accepted;  // if true, that person already used their vote
        address peerReviewer; // the person that the voter chooses to delegate their vote to instead of voting themselves
        string documentHash;   // index of the proposal that was voted for
        uint amountReceived;
    }

    address public contractOwner;
    //mapping(address => beneficiary) public beneficiaries;
    address[] public bens;
    beneficiary[] public beneficiaries;

    constructor() payable public{
        contractOwner = msg.sender;
        peerReviewNeeded = false;
    }

    function setContractDetails(address[] b, uint ta, uint ba, bool peer, bool docHash) public {
        require(msg.sender == contractOwner);
        totalAmount = ta;
        bonusAmount = ba;
        peerReviewNeeded = peer;
        documentProofNeeded = docHash;
        setBeneficiaries(b);
        status = contractState.Created;
    }

    function setBeneficiaries(address[] b) public{
        require(msg.sender == contractOwner);
        for (uint i = 0; i < b.length; i++) {
            beneficiaries.push(beneficiary({
                    selfData: i,
                    myAddress: b[i],
                    authorized: true,
                    accepted:false,
                    peerReviewer: b[i],
                    myPeer: b[i],
                    status: beneficiaryState.Initiated,
                    documentHash: "",
                    amountReceived: 0
                }));
        }
        bens = b;
        amountPerHead = address(this).balance / (beneficiaries.length);
    }

    function getContractOwner() public constant returns(address owner){
        owner = contractOwner;
    }

    function getMyData() public  constant returns(uint, bool, bool, address, address, string, uint, beneficiaryState){
        address me = msg.sender;
        for(uint i=0;i<bens.length;i++){
            if(me == bens[i]){
                return (beneficiaries[i].selfData, beneficiaries[i].authorized,
                    beneficiaries[i].accepted, beneficiaries[i].peerReviewer, beneficiaries[i].myPeer,
                    beneficiaries[i].documentHash, beneficiaries[i].amountReceived, beneficiaries[i].status);
            }
        }
    }

    function setSelfData(uint data, string dHash) public{
        address me = msg.sender;
        for(uint i=0;i<bens.length;i++){
            if(me == bens[i]){
                beneficiaries[i].selfData = data;
                beneficiaries[i].documentHash = dHash;
                if(peerReviewNeeded == true){
                    beneficiaries[i].status = beneficiaryState.ReadyForReview;
                    beneficiaries[i].accepted = true;
                }else{
                    beneficiaries[i].status = beneficiaryState.Completed;
                    distributeAmountVirtual();
                }
                break;
            }
        }
    }

    function distributeAmountx() public {
        for(uint i=0;i<beneficiaries.length;i++){
            if(beneficiaries[i].status == beneficiaryState.Completed){
                beneficiaries[i].myAddress.transfer(1);
                beneficiaries[i].status = beneficiaryState.Distributed;
            }
        }
    }

    function distributeAmountVirtual() public {
        for(uint i=0;i<beneficiaries.length;i++){
            if(beneficiaries[i].status == beneficiaryState.Completed){
                beneficiaries[i].myAddress.transfer(amountPerHead);
                beneficiaries[i].amountReceived = amountPerHead;
                beneficiaries[i].status = beneficiaryState.Distributed;
            }
        }
    }

    function distributeForAll() public {
        for(uint i=0;i<beneficiaries.length;i++){
            if(beneficiaries[i].status != beneficiaryState.Distributed ){
                beneficiaries[i].myAddress.transfer(amountPerHead);
                beneficiaries[i].amountReceived = amountPerHead;
                beneficiaries[i].status = beneficiaryState.Distributed;
            }
        }
    }

    function distributeForAddress(address bene, uint amountToTransfer) public {
        bene.transfer(amountToTransfer);
    }

     function distributeForAddressBalance(address bene) public {
        bene.transfer(address(this).balance);
    }


    function closePeerReview(address target, bool review) public{
        for(uint i=0;i<beneficiaries.length;i++){
            if(beneficiaries[i].myAddress == target && beneficiaries[i].peerReviewer == msg.sender){
                if(beneficiaries[i].status != beneficiaryState.Distributed){
                    beneficiaries[i].accepted = review;
                    beneficiaries[i].status = beneficiaryState.Completed;
                    distributeAmountVirtual();
                }
            }

        }
    }

    function withdrawContract() public{
        require(msg.sender == contractOwner);
        contractOwner.transfer(address(this).balance);
    }

    function getContractStatus() public constant returns (uint, uint, uint, uint, uint, uint, uint, uint){
        uint total = 0;
        uint initial = 0;
        uint ready = 0;
        uint completed = 0;
        uint distributed = 0;

        for(uint i=0;i<beneficiaries.length;i++){
            total ++;
            beneficiary storage b = beneficiaries[i];
            if(b.status == beneficiaryState.Initiated){
                initial++;
            }
            if(b.status == beneficiaryState.ReadyForReview){
                ready++;
            }
            if(b.status == beneficiaryState.Completed){
                completed++;
            }
            if(b.status == beneficiaryState.Distributed){
                distributed++;
            }
        }
        return (total, initial, ready, completed, distributed, totalAmount, amountPerHead, address(this).balance);
    }

    function getBeneficiaries() public constant returns(address[]){
        return bens;
        //for()
    }


    function getContractSetup() public constant returns(uint, uint, bool, bool){
        return (totalAmount, bonusAmount, peerReviewNeeded, documentProofNeeded);
    }
}