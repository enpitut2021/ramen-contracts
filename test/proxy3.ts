import { ethers } from "hardhat";
import { expect } from "chai";
import { toZeroX } from "./utils";
import { AbiCoder } from "@ethersproject/abi";
import { Contract } from "ethers";
import { sha256 } from "@ethersproject/sha2";

const mynaPubkeyExp = "010001";
const mynaPubkeyMod =
  "C2E48C45C07363E246BE44407C8AF5317CBCCD3AA8BE5D26129224525AC9FD73BC65296102D48744600952F0493C397657C966E2564FF9EF5175357EEC9628036096326107A90BD538F67390AAECBCD85672BDC66F088B3F1FA0657009C146DBEC38111C50757358E3016803CF5ECE665927B377AFDF058432A624B372D2E39CF534AB9ED449DA12BA239FE0DD96F65C72CCEA6B6BFD9733C41E90EDEE1F842078AC5CDE7C95C6242A322516EF22927F35ABB8AFE8327633D7DED0959384D205853B84726FABED29182F0213B6A74F118651D2C4C415B8253D3AC2D339C8775361B6201849FE99626F591F558C5C916A79182C856BB1599AD12BE5D33748E799";

describe("Proxy3", () => {
  let jpyc: Contract;
  let proxy: Contract;
  beforeEach(async () => {
    const JPYC = await ethers.getContractFactory("JPYC");
    jpyc = await JPYC.deploy();
    await jpyc.deployed();

    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const Proxy = await ethers.getContractFactory("ProxyMock", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    proxy = await Proxy.deploy(toZeroX(mynaPubkeyExp), toZeroX(mynaPubkeyMod));
    await proxy.deployed();

    await jpyc.transfer(proxy.address, 1);
  });

  it("should verify", async () => {
    const target = jpyc.address;
    expect(target).to.equal("0x67d269191c92Caf3cD7723F116c85e6E9bf55933");
    const nonce = "0x00";
    const arg = jpyc.interface.encodeFunctionData("approve", [
      jpyc.address,
      "0x02",
    ]);
    const toHash = new AbiCoder().encode(
      ["address", "bytes", "uint256"],
      [target, arg, nonce]
    );
    expect(sha256(toHash)).to.be.equal(
      "0x49e3bbca76adff9c099bae375e8e4b9c69ab6ab269d037020fc0d1c19e7fea33"
    );
    const signature = toZeroX(
      "6b140a3a09c9823253ff598c9ecf349778df52a6b2a7c27546101a43e69b17aa58d5162516acb5bc83f34e84d2ebe6de30b1146262fafed9ab4d67e5b0252012285ac97913789aa2d0d2448fbb3a79d8b606e0a6fd6c52a5f13d6cf698cccc3e9c3c5d7704c8671a0f5cbe6d496f728cb2034ccc60c9ccb6305abc14207bb55bad7e55dc8bfdc485add9dc5ca741524d5d02506f60a258954ed1734bcf30dcd99c3e70b1644b6c8935fb704ef1578f6c2379ba2eab81d0cd16249e77a86eca62e6cc1da3506f6777b519b059b7b1496c9f0bf731763dab59a4e5f8b4ecab18f119ec456e3a66030341cb1b282b5662fdf855131205d2717f8c98e565c1ce2557"
    ); // from myna
    await proxy.proxy(target, nonce, arg, signature);
    const allowance = await jpyc.allowance(proxy.address, jpyc.address);

    expect(allowance.toNumber()).to.equal(2);
  });
  it("should calculate hash in contract", async () => {
    const target = jpyc.address;
    const nonce = "0x00";
    const arg = jpyc.interface.encodeFunctionData("approve", [
      jpyc.address,
      "0x02",
    ]);
    const toHashInContract = await proxy.proxyMock3(target, nonce, arg, "0x00");

    const toHash = new AbiCoder().encode(
      ["address", "bytes", "uint256"],
      [target, arg, nonce]
    );
    expect(toHash).to.be.equal(toHashInContract);
  });
});
