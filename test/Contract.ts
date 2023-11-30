import { ethers } from "hardhat";
import { expect } from "chai";

describe("Contract Test", () => {
  let owner: any;
  let addr1: any;
  let addr2: any;
  let addr3: any;
  let addr4: any;
  let provider: any;

  let contract: any;

  async function deployContract() {
    const ContractFactory = await ethers.getContractFactory("PledgePost");
    const contract = await upgrades.deployProxy(ContractFactory, [
      owner.address,
    ]);
    return contract;
  }

  beforeEach(async () => {
    [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
    contract = await deployContract();
    provider = ethers.provider;
  });
  describe("Basic functions", () => {
    it("should post article", async () => {
      await contract.postArticle(
        "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq"
      );
      expect(await contract.getAuthorArticle(owner.address, 0)).to.deep.equal([
        0,
        owner.address,
        "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq",
        0,
      ]);
    });

    it("should donate", async () => {
      await contract.postArticle(
        "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq"
      );
      const donation = { value: ethers.parseEther("100") };
      await contract.connect(addr1).donateToArticle(owner.address, 0, donation);
      expect(await contract.getDonatedAmount(owner.address, 0)).to.equal(
        ethers.parseEther("100")
      );
      expect(
        await contract.checkOwner(addr1.address, owner.address, 0)
      ).to.equal(true);
    });

    it("should create round", async () => {
      await contract.createRound(
        ethers.toUtf8Bytes("Initial Round"),
        ethers.toUtf8Bytes(
          "This is the first round of the PledgePost! Enjoy to write something awesome!"
        ),
        1699509663,
        1702101663
      );
      expect(await contract.getRoundLength()).to.equal(1);
    });

    it("should apply round", async () => {
      await contract.createRound(
        ethers.toUtf8Bytes("Initial Round"),
        ethers.toUtf8Bytes(
          "This is the first round of the PledgePost! Enjoy to write something awesome!"
        ),
        1699509663,
        1702101663
      );
      await contract.postArticle(
        "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq"
      );
      await contract.activateRound(1);
      await contract.applyForRound(1, 0);
      const round1 = await contract.getRound(1);
      expect(await contract.getAppliedRound(owner.address, 0)).to.deep.equal(
        round1
      );
    });
    it("should deposit", async () => {
      await contract.createRound(
        ethers.toUtf8Bytes("Initial Round"),
        ethers.toUtf8Bytes(
          "This is the first round of the PledgePost! Enjoy to write something awesome!"
        ),
        1699509663,
        1702101663
      );
      await contract.activateRound(1);
      await contract.postArticle(
        "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq"
      );
      await contract.applyForRound(1, 0);
      await contract.deposit(1, { value: ethers.parseEther("100") });
      let round = await contract.getRound(1);
      const poolbalance = await provider.getBalance(round.poolAddress);
      expect(poolbalance).to.equal(ethers.parseEther("100"));
    });
    it("should add role", async () => {
      await contract.addAdmin(addr1.address);
      expect(await contract.checkAdminRole(addr1.address)).to.equal(true);
    });
  });
  describe("QF related tests", () => {
    it("total donation should be 100", async () => {
      await contract.createRound(
        ethers.toUtf8Bytes("Initial Round"),
        ethers.toUtf8Bytes(
          "This is the first round of the PledgePost! Enjoy to write something awesome!"
        ),
        1699509663,
        1702101663
      );
      await contract.activateRound(1);
      await contract.postArticle(
        "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq"
      );

      await contract.connect(addr1).donateToArticle(owner.address, 0, {
        value: ethers.parseEther("100"),
      });
      expect(await contract.getDonatedAmount(owner.address, 0)).to.equal(
        ethers.parseEther("100")
      );
    });
    it("should donate within round", async () => {
      await contract.createRound(
        ethers.toUtf8Bytes("Initial Round"),
        ethers.toUtf8Bytes(
          "This is the first round of the PledgePost! Enjoy to write something awesome!"
        ),
        1699509663,
        1702101663
      );
      await contract.postArticle(
        "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq"
      );
      await contract.connect(addr1).donateToArticle(owner.address, 0, {
        value: ethers.parseEther("100"),
      });
      await contract.activateRound(1);
      await contract.applyForRound(1, 0);
      await contract.connect(addr1).donateToArticle(owner.address, 0, {
        value: ethers.parseEther("100"),
      });
      const sqrt100 = await contract.getSquareRoot(ethers.parseEther("100"));

      expect(await contract.getDonatedAmount(owner.address, 0)).to.equal(
        ethers.parseEther("200")
      );
      expect(
        await contract.getSqrtSumRoundDonation(owner.address, 0, 1)
      ).to.equal(sqrt100);
      await contract
        .connect(addr1)
        .donateToArticle(owner.address, 0, { value: ethers.parseEther("100") });
      expect(await contract.getDonatedAmount(owner.address, 0)).to.equal(
        ethers.parseEther("300")
      );
      expect(
        await contract.getSqrtSumRoundDonation(owner.address, 0, 1)
      ).to.equal(sqrt100 + sqrt100);
    });

    it("should Allocate", async () => {
      const contract = await deployContract();
      await contract.createRound(
        ethers.toUtf8Bytes("Initial Round"),
        ethers.toUtf8Bytes(
          "This is the first round of the PledgePost! Enjoy to write something awesome!"
        ),
        1699509663,
        1702101663
      );
      await contract.activateRound(1);
      await contract.postArticle(
        "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq"
      );
      await contract
        .connect(addr1)
        .donateToArticle(owner.address, 0, { value: ethers.parseEther("100") });
      await contract.applyForRound(1, 0);
      await contract
        .connect(addr1)
        .donateToArticle(owner.address, 0, { value: ethers.parseEther("100") });
      expect(await contract.getDonatedAmount(owner.address, 0)).to.equal(
        ethers.parseEther("200")
      );
      const sqrt100 = await contract.getSquareRoot(ethers.parseEther("100"));
      expect(
        await contract.getSqrtSumRoundDonation(owner.address, 0, 1)
      ).to.equal(sqrt100);
      await contract
        .connect(addr1)
        .donateToArticle(owner.address, 0, { value: ethers.parseEther("100") });
      expect(await contract.getDonatedAmount(owner.address, 0)).to.equal(
        ethers.parseEther("300")
      );
      expect(
        await contract.getSqrtSumRoundDonation(owner.address, 0, 1)
      ).to.equal(sqrt100 + sqrt100);
      await contract.deposit(1, { value: ethers.parseEther("100") });
      await contract.Allocate(1);

      expect(await contract.getAllocation(1, owner.address, 0)).to.equal(
        await contract.getMatchingAmount(1, owner.address, 0)
      );
    });
    it("should allocate multiple article", async () => {
      const contract = await deployContract();
      await contract.createRound(
        ethers.toUtf8Bytes("Initial Round"),
        ethers.toUtf8Bytes(
          "This is the first round of the PledgePost! Enjoy to write something awesome!"
        ),
        1699509663,
        1702101663
      );
      await contract.activateRound(1);
      // post articles
      await contract.postArticle(
        "bafybeia3mjq6a3556emeiqhvtkvhckesulygvuknhfriye4ucvd62yvnuq"
      );
      await contract.connect(addr1).postArticle("addr1");
      await contract.connect(addr2).postArticle("addr2");
      await contract.connect(addr3).postArticle("addr3");
      await contract.connect(addr3).postArticle("addr3 again");

      // donate to article
      await contract
        .connect(addr4)
        .donateToArticle(owner.address, 0, { value: ethers.parseEther("100") });
      await contract
        .connect(addr4)
        .donateToArticle(addr1.address, 0, { value: ethers.parseEther("100") });
      await contract
        .connect(addr4)
        .donateToArticle(addr2.address, 0, { value: ethers.parseEther("100") });
      await contract
        .connect(addr4)
        .donateToArticle(addr3.address, 0, { value: ethers.parseEther("100") });

      // apply for round
      await contract.connect(addr1).applyForRound(1, 0);
      await contract.connect(addr2).applyForRound(1, 0);
      await contract.connect(addr3).applyForRound(1, 0);
      await contract.connect(addr3).applyForRound(1, 1);
      await contract.applyForRound(1, 0);

      await contract.connect(addr4).donateToArticle(addr1.address, 0, {
        value: ethers.parseEther("1000"),
      });
      await contract
        .connect(addr4)
        .donateToArticle(addr2.address, 0, { value: ethers.parseEther("500") });
      await contract
        .connect(addr4)
        .donateToArticle(addr2.address, 0, { value: ethers.parseEther("500") });
      await contract
        .connect(addr4)
        .donateToArticle(addr3.address, 0, { value: ethers.parseEther("250") });
      await contract
        .connect(addr4)
        .donateToArticle(addr3.address, 0, { value: ethers.parseEther("250") });
      await contract
        .connect(addr4)
        .donateToArticle(addr3.address, 1, { value: ethers.parseEther("250") });
      await contract
        .connect(addr4)
        .deposit(1, { value: ethers.parseEther("100") });
      await contract.Allocate(1);
      expect(await contract.getAllocation(1, owner.address, 0)).to.equal(
        await contract.getMatchingAmount(1, owner.address, 0)
      );
      expect(await contract.getAllocation(1, addr1.address, 0)).to.equal(
        await contract.getMatchingAmount(1, addr1.address, 0)
      );
      expect(await contract.getAllocation(1, addr2.address, 0)).to.equal(
        await contract.getMatchingAmount(1, addr2.address, 0)
      );
      expect(await contract.getAllocation(1, addr3.address, 0)).to.equal(
        await contract.getMatchingAmount(1, addr3.address, 0)
      );
      expect(await contract.getAllocation(1, addr3.address, 1)).to.equal(
        await contract.getMatchingAmount(1, addr3.address, 1)
      );
    });
  });
});
