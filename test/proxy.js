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
  it("should verify a signature", async () => {
    const proxy = await Proxy.new();
    const instance = await Proxy.deployed();

    const msg1Sha256 = "97d035e32036a670058f2be4e008a7c56355489750a5da6f2af342db4a968e99"; // sha256("message1")
    
    const msg1Sig = "866B66D33D512E5D4BBE37A92EFE3B94FAC8C36A914A4E18CA265F60FD10EF99BE3ECA7D1DB6726FEB2CEAA13A8D4162DD54AE605BBA73CF5ACE1F944901791C14B2E73CCD1271CE8D28B6EF2E0452703B8CD26B5CAA16DE695B0C239FBACC3B63B57358EF8794C84EF5FFEA2C54593CA3533E6FAFBB1A966D0730F1F2ACDFF7FC84786A89DE95AFA595D4589F6CE7DFF017193F8E2540684778277B7C2AB0F0F8324B7A355990CAF459948B6B5B97F6F00D0684178A84328A88384904FD5723BC51A0532053E39B996366B440177585ABCE3D163FE0C544CF9BA0E4FAEEB282460BF2B009A0AFC217430434C27941EF3123095BA0D19E6C10DCB4046201159B" // sign(sha256("message1"), 青木のカードの秘密鍵)
    
    const result = await instance.verifySignature("0x" + msg1Sha256, "0x" + msg1Sig);
    assert.ok(result, "何これ");
  }
});
