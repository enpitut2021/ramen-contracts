import { ethers } from "hardhat";
import { expect } from "chai";
import { mutateOneChar, toZeroX } from "./utils";

describe("Verifier", function () {
  const msg1Sha256 =
    "97d035e32036a670058f2be4e008a7c56355489750a5da6f2af342db4a968e99"; // sha256("message1")

  const msg1Sig =
    "866B66D33D512E5D4BBE37A92EFE3B94FAC8C36A914A4E18CA265F60FD10EF99BE3ECA7D1DB6726FEB2CEAA13A8D4162DD54AE605BBA73CF5ACE1F944901791C14B2E73CCD1271CE8D28B6EF2E0452703B8CD26B5CAA16DE695B0C239FBACC3B63B57358EF8794C84EF5FFEA2C54593CA3533E6FAFBB1A966D0730F1F2ACDFF7FC84786A89DE95AFA595D4589F6CE7DFF017193F8E2540684778277B7C2AB0F0F8324B7A355990CAF459948B6B5B97F6F00D0684178A84328A88384904FD5723BC51A0532053E39B996366B440177585ABCE3D163FE0C544CF9BA0E4FAEEB282460BF2B009A0AFC217430434C27941EF3123095BA0D19E6C10DCB4046201159B"; // sign(sha256("message1"), 青木のカードの秘密鍵)

  const mynaPubkeyDer =
    "30820122300D06092A864886F70D01010105000382010F003082010A0282010100C2E48C45C07363E246BE44407C8AF5317CBCCD3AA8BE5D26129224525AC9FD73BC65296102D48744600952F0493C397657C966E2564FF9EF5175357EEC9628036096326107A90BD538F67390AAECBCD85672BDC66F088B3F1FA0657009C146DBEC38111C50757358E3016803CF5ECE665927B377AFDF058432A624B372D2E39CF534AB9ED449DA12BA239FE0DD96F65C72CCEA6B6BFD9733C41E90EDEE1F842078AC5CDE7C95C6242A322516EF22927F35ABB8AFE8327633D7DED0959384D205853B84726FABED29182F0213B6A74F118651D2C4C415B8253D3AC2D339C8775361B6201849FE99626F591F558C5C916A79182C856BB1599AD12BE5D33748E7990203010001"; // 青木のカードの公開鍵
  const mynaPubkeyExp = "010001";
  const mynaPubkeyMod =
    "C2E48C45C07363E246BE44407C8AF5317CBCCD3AA8BE5D26129224525AC9FD73BC65296102D48744600952F0493C397657C966E2564FF9EF5175357EEC9628036096326107A90BD538F67390AAECBCD85672BDC66F088B3F1FA0657009C146DBEC38111C50757358E3016803CF5ECE665927B377AFDF058432A624B372D2E39CF534AB9ED449DA12BA239FE0DD96F65C72CCEA6B6BFD9733C41E90EDEE1F842078AC5CDE7C95C6242A322516EF22927F35ABB8AFE8327633D7DED0959384D205853B84726FABED29182F0213B6A74F118651D2C4C415B8253D3AC2D339C8775361B6201849FE99626F591F558C5C916A79182C856BB1599AD12BE5D33748E799";

  const mynaSigEncoded =
    "0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff003031300d06096086480165030402010500042097d035e32036a670058f2be4e008a7c56355489750a5da6f2af342db4a968e99";
  it("should verify RSA signature", async () => {
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const VerifierHelper = await ethers.getContractFactory("VerifierHelper", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    const verifierHlpr = await VerifierHelper.deploy();
    await verifierHlpr.deployed();

    const result = await verifierHlpr.verifySignature(
      toZeroX(mynaPubkeyMod),
      toZeroX(mynaPubkeyExp),
      toZeroX(msg1Sha256),
      toZeroX(msg1Sig)
    );
    expect(result).to.be.true;
  });
  it("should primitively verify RSA signature", async () => {
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const VerifierHelper = await ethers.getContractFactory("VerifierHelper", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    const verifierHlpr = await VerifierHelper.deploy();
    await verifierHlpr.deployed();

    const result = await verifierHlpr.bigModExp(
      toZeroX(msg1Sig),
      toZeroX(mynaPubkeyExp),
      toZeroX(mynaPubkeyMod)
    );
    expect(result).to.equal(toZeroX(mynaSigEncoded));
  });

  it("should check valid padded message", async () => {
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const VerifierHelper = await ethers.getContractFactory("VerifierHelper", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    const verifierHlpr = await VerifierHelper.deploy();
    await verifierHlpr.deployed();

    const result = await verifierHlpr.checkPaddedString(
      toZeroX(mynaSigEncoded),
      toZeroX(msg1Sha256)
    );
    expect(result).to.be.true;
  });
  it("should check invalid padded message", async () => {
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const VerifierHelper = await ethers.getContractFactory("VerifierHelper", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    const verifierHlpr = await VerifierHelper.deploy();
    await verifierHlpr.deployed();

    const result = await verifierHlpr.checkPaddedString(
      toZeroX(mutateOneChar(mynaSigEncoded, 32, "e")),
      toZeroX(msg1Sha256)
    );
    expect(result).to.be.false;
  });
  it("should check invalid padded message", async () => {
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const VerifierHelper = await ethers.getContractFactory("VerifierHelper", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    const verifierHlpr = await VerifierHelper.deploy();
    await verifierHlpr.deployed();
    const result = await verifierHlpr.checkPaddedString(
      toZeroX(mutateOneChar(mynaSigEncoded, 3, "0")),
      toZeroX(msg1Sha256)
    );
    expect(result).to.be.false;
  });
  it("should verify RSA signature", async () => {
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const VerifierHelper = await ethers.getContractFactory("VerifierHelper", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    const verifierHlpr = await VerifierHelper.deploy();
    await verifierHlpr.deployed();

    const result = await verifierHlpr.verifySignature(
      toZeroX(mynaPubkeyMod),
      toZeroX(mynaPubkeyExp),
      toZeroX(
        "3ce961c3b814f135facb99b07dd233885144da766bd43a200cebec987e4df6d3"
      ),
      toZeroX(
        "3a57807731ce3df983c4767ca079aef488799e5cfa6e1bc96d334455d24185b43afbfdacafeb99d082ddfa724478f5164d7fcbb477f2199598b6ecba510a27da0fa535b3db5be44641f37a408ab916c1e1e3fffd74c83f97559c9a447ad0980bab215e4a45b564ce086504a310e9866ff24c27f5312f06db6591678227e0f94c60a000da5e7d3af5069eb43e9820a8d83a573158c6ed0f7ac2ae658e3c9db8692596301040f519a261d6cd81f7e8cc6868e17a94f9865710ab0e3452c1629da6da1b7f193f5ad9f61e260787e312b6f469f78dd7a646f2226d7c93dead626efa9d0ce9797d673a2fff026e97fdc1e83a1d18002511e3323b2f2205e06451a2eb"
      )
    );
    expect(result).to.be.true;
  });
  it("should fail verifying RSA signature", async () => {
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const VerifierHelper = await ethers.getContractFactory("VerifierHelper", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    const verifierHlpr = await VerifierHelper.deploy();
    await verifierHlpr.deployed();

    const result = await verifierHlpr.verifySignature(
      toZeroX(mynaPubkeyMod),
      toZeroX(mynaPubkeyExp),
      toZeroX(
        "3ce961c3b814f135facb99b07dd233885144da766bd43a200cebec987e4df6d3"
      ),
      toZeroX(
        "16a8de6a2ef20aa6e5355e84f5de0c150aff322538e17b350b3083f0fc2dd4c70729c0dffb0576923d407d5c1f8485b0f827981bf916f67a0095472c363cd3c89069e563c995343a22c1bf583699856efe2e0ac5edcdc9e66d99c8a4c18e88952420bb68a7a2687d1862ca891b6d53388b219b1c3ad9f7fc313b2a11395d49f273c9b60c605e03685df582addc47110e07c0460d6271a0212cc3bc905945f8f9d827ba5ca0c0fb8285951e89ce9926572b65e0b5a746c5387ce201a278a86b48525033a0add974422e175aa9363799bd99d7fe03ddb1c55e7af7d473cb3eed8504dcc4975bf90db40f7598f5eb9cd755f88f6ac6598392dd5c424fb4ca285e98"
      ) // DigestInfoなしで打ち込んだ
    );
    expect(result).to.be.false;
  });
});
