//SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

contract CrowdFunding {
    mapping(address => uint) public participants;
    address public owner;
    uint public noOfParticipants;
    uint public minimumAmount;
    uint public deadline;
    uint public targetAmount;
    uint public raisedAmount;

    struct Request{
       string description;
       address payable recipient;
       uint value;
       bool completed;
       uint noOfVoters;
       mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;

    uint public numRequests;

    constructor(uint _targetAmount, uint _deadline) {
        targetAmount = _targetAmount;
        deadline = block.timestamp + _deadline;
        minimumAmount = 100 wei;
        owner = msg.sender;
    }

    function participate() public payable{
        require(block.timestamp < deadline, "Auction is over!");
        require(msg.value >= minimumAmount, "min 100 wel is requ'red to participate");

        if(participants[msg.sender] == 0){
            noOfParticipants++;
        }

        participants[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    receive() payable external{
        participate();
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getRefund() public{
        require(block.timestamp > deadline && raisedAmount < targetAmount);
        require(participants[msg.sender] >0 );

        payable(msg.sender).transfer(participants[msg.sender]);

        participants[msg.sender] = 0;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "only owner can do it");
        _;   
    }

    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyOwner{
        Request storage newRequest = requests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint _numRequest) public{
        require(participants[msg.sender] >0, "You must participate to the Auction!");
        Request storage thisRequest = requests[_numRequest];

        require(thisRequest.voters[msg.sender] == false, "You can vote only once for a request!");
        thisRequest.voters[msg.sender] == true;
        thisRequest.noOfVoters++;
    
    }

    function makePayment(uint _numRequest) public onlyOwner{
        require(raisedAmount >= targetAmount);
        Request storage thisRequest = requests[_numRequest];
        require(thisRequest.completed == false, "this request has already completed");
        require(thisRequest.noOfVoters > noOfParticipants/2);

        thisRequest.recipient.transfer(thisRequest.value);
    }

}
//This code is a project, no financial advice;