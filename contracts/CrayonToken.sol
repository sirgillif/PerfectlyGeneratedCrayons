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
    
    // modifier positiveVal(){
       
    //     _;
    // } 
    // need this to make sure that there is no int overflow on sending the tokens to a charity 
    // modifier positiveAmount(uint256 _amount) {
    //     require
    // }

    constructor() public {
        owner = msg.sender;
    }
    
    function getCurBalInWei() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    //When buying tokens each buyer will get 2 tokens for every finney they spend.
    //The contract wil not allow for mixed amounts to keep the math simple so any change will be returned 
    //(so if there is a change sent after the gas cost will)
    
    function buyToken() public payable {
        require((balanceOf[msg.sender] + 2*(msg.value/(10**15))) >= balanceOf[msg.sender]);

        uint256 amount = msg.value/(10**15);

        balanceOf[msg.sender]+=2*amount;

        uint256 decimalPart = msg.value % (10**15);

        emit FundTransfer(msg.sender, 2*amount, true);
            // tarnsfer the decimal points back to user

        msg.sender.transfer(decimalPart);
    }
    
    function getMybalance() public view returns (uint256) {
        return balanceOf[msg.sender];
    }
    
    function getbalance(address charity) public view returns (uint256) {
        return balanceOf[charity];
    }

    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        require((balanceOf[to] + value) >= balanceOf[to]);
        balanceOf[msg.sender] -= value; 
        balanceOf[to] += value;
    }

    //will take in an amount in tokens, ethers, or finney (to be converted TO token integer on the front end)
    function withdraw(uint256 value) public payable {
        require(balanceOf[msg.sender] >= value);

        uint256 amountToSend = (value/2) *(10**15);

        msg.sender.transfer(amountToSend);

        balanceOf[msg.sender] -= value;

        emit FundTransfer(msg.sender, value, true);
        
    }
    
    //---------------------------------------
    //----- Voting and Charity creation -----
    //---------------------------------------
    
    //the durationshould be the amount of time that the contract stays alive (in seconds)
    function createcharity(string _name, uint256 _initialAmt,uint _duration) public{
        require(_initialAmt>0);
        Voting charity = new Voting(msg.sender,_name,_initialAmt,_duration);
        charities[msg.sender] = charity;
        emit NewCharity(msg.sender, _duration, _name, block.timestamp);
        
    }
    
    function supportCharity(address charityAddr, uint256 _amount) public{
        require(balanceOf[charityAddr]+_amount>balanceOf[charityAddr]);
        require(balanceOf[msg.sender] >= _amount);
        if(charities[charityAddr].vote(_amount)){
            balanceOf[charityAddr]+=_amount;
            balanceOf[msg.sender]-=_amount;
        }
    }
    
    function checkFundraiserBalance(address charityAddr) public view returns(uint256){
        return charities[charityAddr].getVotes();
    }
    
    function checkCharityName(address charityAddr) public view returns(string){
        return charities[charityAddr].getCharityName();
    }
    //gets the time in second so need to convert to days/hours/minutes
    function getTimeLeftInFundraiser(address charityAddr) public view returns(uint){
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
    uint startTime =now;
    uint endTime;
    Candidate public charity;

    constructor(address _address, string _name, uint256 _initialAmt,uint _duration) public{
        require ( _initialAmt > 0);
        charity = Candidate(_address, _name, _initialAmt, _duration);
        endTime=startTime+_duration;
    }
    
    function getVotes () public view returns (uint256) {
        return charity.votes;
    }
    
    function getCharityName () public view returns (string) {
        return charity.beneficiaryName;
    }
    
    function vote(uint256 _amount) public returns(bool){
        require(_amount > 0);
        require(charity.votes + _amount >= charity.votes );
        if(now< endTime){
            charity.votes += _amount;
            return true;
        }
        return false;
    }

    function getRemainingDuration() public view returns (uint){
        if(now< endTime){
            return (endTime-now);
        }
        
        return 0;
    }
    
}