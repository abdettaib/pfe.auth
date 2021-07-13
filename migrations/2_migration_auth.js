const Authentification = artifacts.require("authentification");

module.exports = function (deployer) {
  deployer.deploy(Authentification);
};
