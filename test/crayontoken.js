const timeTravel = require('../test-helpers/timeTravel');

var CrayonToken = artifacts.require("./CrayonToken.sol");

contract('CrayonToken', function(accounts) {
  let crayonToken;

  beforeEach(async function () {
    crayonToken = await CrayonToken.new();
  });


  it('Can people buy the token and see their balance?', async function () {
    const sender = accounts[1];
    const price = 10 * Math.pow(10, 15);
    await crayonToken.buyToken({value: price, from: sender});
    const senderBalance = await crayonToken.getMybalance({ from: sender});
    return assert.equal(20, senderBalance);
  });

  it('Can people buy the token and does the contract get the correct balance?', async function () {
    const owner = accounts[0];
    const sender = accounts[1];
    const price = 10 * Math.pow(10, 15);
    await crayonToken.buyToken({value: price, from: sender});
    let contractBalance = await crayonToken.getCurBalInWei({ from: owner});

    return assert.equal(price, contractBalance);
  });

  it('Can people check balances of charities?', async function () {
    const checker = accounts[2];
    const sender = accounts[1];

    const price = 25 * Math.pow(10, 15);

    await crayonToken.buyToken({value: price, from: sender});
    const checkBalance = await crayonToken.getbalance(sender,{ from: checker});
    
    return assert.equal(50, checkBalance);
  });

  it('Can you transfer funds from one account to another?', async function () {
    const fromAccount = accounts[2];
    const toAccount = accounts[1];

    const price = 35 * Math.pow(10, 15);

    await crayonToken.buyToken({value: price, from: fromAccount});
    await crayonToken.transfer(toAccount,35,{from: fromAccount});

    const checkBalance = await crayonToken.getbalance(toAccount);
    
    return assert.equal(35, checkBalance);
  });


  it('Can you withdraw your funds to get your ethers back?', async function () {
    const sender = accounts[2];
    

    const price = 20* Math.pow(10, 15);

    await crayonToken.buyToken({value: price, from: sender});

    await crayonToken.withdraw(25,{ from: sender});


    let checkBalance = await crayonToken.getbalance(sender);

    checkBalance= checkBalance.toNumber();
    
    return assert.equal(15, checkBalance);
  });

  it('Can you make a charity?', async function () {
    const owner = accounts[0];
    
    const price = 20* Math.pow(10, 15);
    const duration = 2 * (3600*24);

    await crayonToken.buyToken({value: price, from: owner});

    await crayonToken.createcharity("children's fund",25,duration,{ from: owner});

    const charityName = await crayonToken.checkCharityName(owner);
    
    return assert.equal("children's fund", charityName);
  });

  it('Can you support a charity?', async function () {
    const owner = accounts[0];
    const supporter =accounts[1];

    const price1 = 20* Math.pow(10, 15);
    const price2 = 100* Math.pow(10, 15);

    const duration = 2 * (3600*24);

    await crayonToken.buyToken({value: price1, from: owner});
    await crayonToken.buyToken({value: price2, from: supporter});

    await crayonToken.createcharity("children's fund",25,duration,{ from: owner});

    await crayonToken.supportCharity(owner,50,{ from: supporter});

    let charityrBalance = await crayonToken.checkFundraiserBalance(owner);

    charityrBalance = charityrBalance.toNumber();
    
    return assert.equal(75, charityrBalance);
  });

  it('get time left to donate', async function () {
    const owner = accounts[0];

    const price1 = 20* Math.pow(10, 15);

    const duration = 2 * (3600*24);

    await crayonToken.buyToken({value: price1, from: owner});

    await crayonToken.createcharity("children's fund",25,duration,{ from: owner});

    let charityTime = await crayonToken.getTimeLeftInFundraiser(owner);

    charityTime = charityTime.toNumber();
    
    return assert(charityTime>0, (charityTime/3600));
  });



});
