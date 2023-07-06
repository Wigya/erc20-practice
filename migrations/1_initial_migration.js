const practice = artifacts.require("ERC20Practice");

module.exports = function (deployer) {
  deployer.deploy(practice);
};
