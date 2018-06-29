pragma solidity ^0.4.18;


contract CrayonToken {
    address owner;
    mapping (address => uint256) public balanceOf;
    mapping (address => Voting) public charities;
    
    event FundTransfer(address backer, uint amount, bool isContribution);
    event NewCharity(address creator, uint duration, string charityName,uint startTime);
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
           
    }
    
    modifier positiveVal(){
        require((balanceOf[msg.sender] + 2*(msg.value/(10**15))) >= balanceOf[msg.sender]);
        _;
    } 
    // need this to make sure that there is no int overflow on sending the tokens to a charity 
    // modifier positiveAmount(uint256 _amount) {
    //     require
    // }

    constructor() public {
        owner = msg.sender;
        
    }
    
    //When buying tokens each buyer will get 2 tokens for every finney they spend.
    //The contract wil not allow for mixed amounts to keep the math simple so any change will be returned 
    //(so if there is a change sent after the gas cost will)
    function buyToken() public payable positiveVal{
        uint256 amount = msg.value/(10**15);
        balanceOf[msg.sender]+=2*amount;
        uint256 decimalPart = msg.value%(10**15);
        emit FundTransfer(msg.sender, amount, true);
            // tarnsfer the decimal points back to user
        msg.sender.transfer(decimalPart);
    }
    
    function getMybalance() public view returns (uint256) {
        return balanceOf[msg.sender];
    }
    
    function getbalance(address doner) public view returns (uint256) {
        return balanceOf[doner];
    }

    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        require((balanceOf[to] + value) >= balanceOf[to]);
        balanceOf[msg.sender] -= value; 
        balanceOf[to] += value;
    }

    //will take in an amount in ethers or finney (to be converted TO finney integer on the front end)
    function withdraw(uint256 value) public {
        require(balanceOf[msg.sender] >= 2*value);
        uint256 amountToSend = 2*value*10**15;
        if (msg.sender.send(amountToSend)){
            balanceOf[msg.sender] -= 2*value;
           emit FundTransfer(msg.sender, value, false);
        }
        
    }

    function kill() private onlyOwner { 
        selfdestruct(owner); 
    } 
    
    //---------------------------------------
    //----- Voting and Charity creation -----
    //---------------------------------------
    
    //the durationshould be the amount of time that the contract stays alive (in seconds)
    function createcharity(string _name, uint256 _initialAmt,uint _duration) public{
        require(_initialAmt>0);
        Voting charity = new Voting(msg.sender,_name,_initialAmt,_duration);
        charities[msg.sender] = charity;
        NewCharity(msg.sender, _duration, _name, block.timestamp);
        
    }
    
    function supportCharity(address charityAddr, uint256 _amount) public{
        require(balanceOf[charityAddr]+_amount>balanceOf[charityAddr]);
        require(balanceOf[msg.sender] >= _amount);
        charities[charityAddr].vote(_amount);
        balanceOf[charityAddr]+=_amount;
        balanceOf[msg.sender]-=_amount;
    }
    
    function checkFundraiserBalance(address charityAddr) public returns(uint256){
        return charities[charityAddr].getVotes();
    }
    
    function checkCharityName(address charityAddr) public returns(string){
        return charities[charityAddr].getCharityName();
    }
    //gets the time in second so need to convert to days/hours/minutes
    function getTimeLeftInFundraiser(address charityAddr) public returns(uint){
        return charities[charityAddr].getRemainingDuration();
    }
    
    
    
    
}


contract Voting {

    struct Candidate {
        address beneficiary;
        string beneficiaryName;
        uint256 votes;
        uint duration;
    }
    uint startTime =block.timestamp;
    Candidate public charity;

    constructor(address _address, string _name, uint256 _initialAmt,uint _duration) public{
        require ( _initialAmt > 0);
        charity = Candidate(_address, _name, _initialAmt, _duration);
    }
    
    function getVotes () public view returns (uint256) {
        return charity.votes;
    }
    
    function getCharityName () public view returns (string) {
        return charity.beneficiaryName;
    }
    
    function vote(uint256 _amount) public {
        require(_amount > 0);
        require(charity.votes + _amount >= charity.votes );
        require(block.timestamp-startTime> charity.duration);
        charity.votes += _amount;
    }
    function getRemainingDuration() returns (uint){
        return block.timestamp-startTime;
    }
    
}