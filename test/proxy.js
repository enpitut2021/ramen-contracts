const Proxy = artifacts.require("Proxy");

contract("Proxy", (accounts) => {
  it("should proxy a function call", async (accounts) => {
    const instance = await Proxy.deployed();
    const result = await instance.verifySignature("0x0001", "0x0002");
    assert.equal(result, true);
  });
});
