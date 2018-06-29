var CrayonToken = artifacts.require("./CrayonToken.sol");

module.exports = function(deployer) {
  deployer.deploy(CrayonToken);
};
