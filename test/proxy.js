const Proxy = artifacts.require("Proxy");

contract("Proxy", (accounts) => {
  it("should deploy a Proxy", async () => {
    const proxy = await Proxy.new();
    const instance = await Proxy.deployed();
    assert.ok(instance.address, "失敗");
  });
  it("should proxy a function call", async () => {
    const proxy = await Proxy.new();
    const instance = await Proxy.deployed();
    const result = await instance.verifySignature("0x01", "0x01");
    assert.ok(result, "何これ");
  });
});
