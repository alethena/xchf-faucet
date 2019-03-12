const XCHF = artifacts.require("contracts/XCHF/CryptoFranc.sol");
const Faucet = artifacts.require("Faucet");

module.exports = function (deployer) {
    deployer.deploy(XCHF, 'Test XCHF', 0).then(() => { return deployer.deploy(Faucet, XCHF.address) });
};