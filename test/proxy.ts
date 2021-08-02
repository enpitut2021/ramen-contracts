import { ethers } from "hardhat";
import { expect } from "chai";
import { toZeroX } from "./utils";
import { Interface } from "@ethersproject/abi";
import { Contract } from "ethers";

const mynaPubkeyExp = "010001";
const mynaPubkeyMod =
  "C2E48C45C07363E246BE44407C8AF5317CBCCD3AA8BE5D26129224525AC9FD73BC65296102D48744600952F0493C397657C966E2564FF9EF5175357EEC9628036096326107A90BD538F67390AAECBCD85672BDC66F088B3F1FA0657009C146DBEC38111C50757358E3016803CF5ECE665927B377AFDF058432A624B372D2E39CF534AB9ED449DA12BA239FE0DD96F65C72CCEA6B6BFD9733C41E90EDEE1F842078AC5CDE7C95C6242A322516EF22927F35ABB8AFE8327633D7DED0959384D205853B84726FABED29182F0213B6A74F118651D2C4C415B8253D3AC2D339C8775361B6201849FE99626F591F558C5C916A79182C856BB1599AD12BE5D33748E799";

describe("Proxy(Initialization)", () => {
  it("should be able to create a proxy", async () => {
    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const Proxy = await ethers.getContractFactory("Proxy", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    const proxy = await Proxy.deploy(
      toZeroX(mynaPubkeyExp),
      toZeroX(mynaPubkeyMod)
    );
    await proxy.deployed();

    const txCount = await proxy.transactionCount();
    expect(txCount.toNumber()).to.equal(0);

    const exponent = await proxy.exponent();
    expect(exponent.toString("hex")).to.equal(toZeroX(mynaPubkeyExp));
  });
});

describe("Proxy(Approve)", () => {
  let jpyc: Contract;
  let proxy: Contract;
  beforeEach(async () => {
    const JPYC = await ethers.getContractFactory("JPYC");
    jpyc = await JPYC.deploy();
    await jpyc.deployed();

    const Verifier = await ethers.getContractFactory("Verifier");
    const verifier = await Verifier.deploy();
    const Proxy = await ethers.getContractFactory("Proxy", {
      libraries: {
        Verifier: verifier.address,
      },
    });
    proxy = await Proxy.deploy(toZeroX(mynaPubkeyExp), toZeroX(mynaPubkeyMod));
    await proxy.deployed();
  });

  it("should proxy transaction", async () => {
    let allowance = await jpyc.allowance(proxy.address, jpyc.address);

    expect(allowance.toNumber()).to.equal(0);

    await proxy.proxyMock(
      jpyc.address,
      "0x00",
      jpyc.interface.encodeFunctionData("approve", [jpyc.address, "0x02"]),
      "0x00"
    );
    allowance = await jpyc.allowance(proxy.address, jpyc.address);

    expect(allowance.toNumber()).to.equal(2);

    await proxy.proxyMock(
      jpyc.address,
      "0x01",
      jpyc.interface.encodeFunctionData("increaseAllowance", [
        jpyc.address,
        "0x07",
      ]),
      "0x00"
    );
    allowance = await jpyc.allowance(proxy.address, jpyc.address);

    expect(allowance.toNumber()).to.equal(9);

    await proxy.proxyMock(
      jpyc.address,
      "0x02",
      jpyc.interface.encodeFunctionData("decreaseAllowance", [
        jpyc.address,
        "0x03",
      ]),
      "0x00"
    );
    allowance = await jpyc.allowance(proxy.address, jpyc.address);

    expect(allowance.toNumber()).to.equal(0x06);
  });
  it("should proxy transaction", async () => {
    let allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(0);

    await proxy.proxyMock(
      jpyc.address,
      "0x00",
      jpyc.interface.encodeFunctionData("approve", [jpyc.address, "0x02"]),
      "0x00"
    );
    allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(2);

    await proxy.proxyMock(
      jpyc.address,
      "0x01",
      jpyc.interface.encodeFunctionData("approve", [jpyc.address, "0x03"]),
      "0x00"
    );
    allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(3);
  });
  it("should fail if nonce < txCount", async () => {
    let allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(0x00);

    await proxy.proxyMock(
      jpyc.address,
      "0x00",
      jpyc.interface.encodeFunctionData("approve", [jpyc.address, "0x02"]),
      "0x00"
    );
    allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(2);

    await proxy.proxyMock(
      jpyc.address,
      "0x01",
      jpyc.interface.encodeFunctionData("increaseAllowance", [
        jpyc.address,
        "0x07",
      ]),
      "0x00"
    );
    allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(9);

    try {
      await proxy.proxyMock(
        jpyc.address,
        "0x00",
        jpyc.interface.encodeFunctionData("decreaseAllowance", [
          jpyc.address,
          "0x03",
        ]),
        "0x00"
      );
    } catch (e) {
      expect(e.message).to.include("Invalid nonce");
    }
    allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(0x09).but.not.equal(0x06);

    try {
      await proxy.proxyMock(
        jpyc.address,
        "0x01",
        jpyc.interface.encodeFunctionData("decreaseAllowance", [
          jpyc.address,
          "0x03",
        ]),
        "0x00"
      );
    } catch (e) {
      expect(e.message).to.include("Invalid nonce");
    }

    allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber())
      .to.equal(0x09)
      .but.not.equal(0x06)
      .and.not.equal(0x03);
  });
  it("should fail if nonce > txCount", async () => {
    let allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(0);

    await proxy.proxyMock(
      jpyc.address,
      "0x00",
      jpyc.interface.encodeFunctionData("approve", [jpyc.address, "0x02"]),
      "0x00"
    );
    allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(2);

    try {
      await proxy.proxyMock(
        jpyc.address,
        "0x02",
        jpyc.interface.encodeFunctionData("increaseAllowance", [
          jpyc.address,
          "0x07",
        ]),
        "0x00"
      );
    } catch (e) {
      expect(e.message).to.include("Invalid nonce");
    }
    allowance = await jpyc.allowance(proxy.address, jpyc.address);
    expect(allowance.toNumber()).to.equal(2).but.not.equal(9);
  });
});
