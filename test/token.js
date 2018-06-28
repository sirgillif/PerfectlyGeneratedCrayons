var Token = artifacts.require("./Token.sol");

contract('Token', function(accounts) {

  it("...should store the value 89.", function() {
    return Token.deployed().then(function(instance) {
        tokenInstance = instance;

      return tokenInstance.set(89, {from: accounts[0]});
    }).then(function() {
      return tokenInstance.get.call();
    }).then(function(storedData) {
      assert.equal(storedData, 89, "The value 89 was not stored.");
    });
  });

});