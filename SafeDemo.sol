pragma solidity ^0.4.11;
contract Sample {

    uint public purchaseValue;
    address public sellerAddress;
    address public buyerAddress;
    enum contractState { Created, InProgress, Completed }
    enum beneficiaryState { Initiated, ReadyForReview, Completed, Distributed }

    bool public peerReviewNeeded;
    bool public documentProofNeeded;
    uint public totalAmount;
    uint public bonusAmount;
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
    }

    address public contractOwner;
    //mapping(address => beneficiary) public beneficiaries;
    address[] public bens;
    beneficiary[] public beneficiaries;

    constructor() public{
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
                    documentHash: ""
                }));
        }
        bens = b;
    }

    function getContractOwner() public constant returns(address owner){
        owner = contractOwner;
    }

    function getMyData() public  constant returns(uint, bool, bool, address, address, string){
        address me = msg.sender;
        for(uint i=0;i<bens.length;i++){
            if(me == bens[i]){
                return (beneficiaries[i].selfData, beneficiaries[i].authorized,
                    beneficiaries[i].accepted, beneficiaries[i].peerReviewer, beneficiaries[i].myPeer,
                    beneficiaries[i].documentHash);
            }
        }
    }

    function getMyDataBeneficiary() public constant returns(uint, bool, bool, address, address, string){
        address me = msg.sender;
        beneficiary storage b;
        bool beneficiaryFound = false;
        for(uint i=0;i<bens.length;i++){
            if(me == beneficiaries[i].myAddress){
                b = beneficiaries[i];
                beneficiaryFound = true;
                break;
            }
        }
        require(beneficiaryFound);
        return (b.selfData, b.authorized, b.accepted, b.peerReviewer, b.myPeer,
                    "beneficiaries[i].documentHash");
    }

    function setSelfData(uint data, string dHash) public{
        address me = msg.sender;
        for(uint i=0;i<bens.length;i++){
            if(me == bens[i]){
                beneficiaries[i].selfData = data;
                beneficiaries[i].documentHash = dHash;
                beneficiaries[i].status = beneficiaryState.ReadyForReview;
                break;
            }
        }
    }

    function closePeerReview(address target, bool review) public{
        for(uint i=0;i<beneficiaries.length;i++){
            if(beneficiaries[i].myAddress == target && beneficiaries[i].peerReviewer == msg.sender){
                beneficiaries[i].accepted = review;
                beneficiaries[i].status = beneficiaryState.Completed;
            }

        }
    }


    function getContractStatus() public constant returns (uint, uint, uint, uint, uint){
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
        return (total, initial, ready, completed, distributed);
    }

    function getBeneficiaries() public constant returns(address[]){
        return bens;
        //for()
    }

    // function setSelfData(uint data) public{
    //     beneficiary storage _beneficiary = beneficiaries[msg.sender];
    //     require(_beneficiary.authorized);
    //     beneficiaries[msg.sender].selfData = data;
    // }

    // function setSelfDataVal(uint data) public{
    //     beneficiary storage _beneficiary = beneficiaries[msg.sender];
    //     require(_beneficiary.authorized);
    //     _beneficiary.selfData = data;
    // }

    // function getSelfData() public constant returns(uint data){
    //     beneficiary storage _beneficiary = beneficiaries[msg.sender];
    //     data  = _beneficiary.selfData;
    // }

    // function getAllSelfData() public constant returns(uint, bool){
    //     beneficiary storage _beneficiary = beneficiaries[msg.sender];
    //     return (_beneficiary.selfData, _beneficiary.authorized);
    // }

    // function getAllSelfDataArray() public constant returns(uint, bool){
    //     return (beneficiaries[msg.sender].selfData, beneficiaries[msg.sender].authorized);
    // }

    // function setDocumentHash(string h) public{
    //     require(beneficiaries[msg.sender].authorized);
    //     beneficiaries[msg.sender].documentHash = h;
    // }

    // function getDocumentHash() public constant returns(string hash){
    //     hash = beneficiaries[msg.sender].documentHash;
    // }

    function getContractSetup() public constant returns(uint, uint, bool, bool){
        return (totalAmount, bonusAmount, peerReviewNeeded, documentProofNeeded);
    }
}