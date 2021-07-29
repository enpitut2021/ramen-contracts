const Proxy = artifacts.require("Proxy");

contract("Proxy", (accounts) => {
  it("should deploy a Proxy", async () => {
    const proxy = await Proxy.new();
    const instance = await proxy.deployed();
    assert.equal(proxy.address, await proxy.address.call(), "助けて");
  });
  it("should proxy a function call", async (accounts) => {
    const instance = await Proxy.deployed();
    const result = await instance.verifySignature("0x01", "0x02");
    assert.equal(result, true, "何これ");
  });
});
