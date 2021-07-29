const Proxy = artifacts.require("Proxy");

contract("Proxy", (accounts) => {
  it("should proxy a function call", async (accounts) => {
    const instance = await Proxy.deployed();
    const result = await instance.verifySignature([0x00], [0x00]);
    assert.equal(result, true);
  });
});
