const { anyValue } = "@nomicfoundation/hardhat-chai-matchers/withArgs";
const { expect } = require("chai")
const { time } = require("@nomicfoundation/hardhat-network-helpers")
const { ethers } = require("hardhat")
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace")

describe("Bets", function (){
    let acc1
    let acc2
    let acc3
    let acc4
    let acc5
    let bets
beforeEach(async function(){
    [acc1, acc2, acc3, acc4, acc5] = await ethers.getSigners()
    const Bets = await ethers.getContractFactory("Bets", acc1)
    bets = await Bets.deploy()
    await bets.deployed()
})

it("Checks the host setting is correct and checks payability is correct to", async function(){
    const temp = await bets.connect(acc1).setHost("It will be rainy tomorrow", 2, 0, {value : 100})
    expect(await bets.host()).to.eq(acc1.address)
    await expect(() =>temp).to.changeEtherBalance(acc1, -100)
    await expect(() =>temp).to.changeEtherBalance(bets, 100)
})

it("Checks the judge setting is correct", async function(){
    const temp = await bets.connect(acc3).setJudge()
    expect(await bets.judges(acc3.address)).to.eq(true)
})

it("Checks the judge setting revert is correct", async function(){
    const temp = await bets.connect(acc3).setJudge()
    await expect(bets.connect(acc3).setJudge()).to.be.revertedWith("This judge has already entered");
})

it("Checks the user setting is correct", async function(){
    await bets.connect(acc1).setHost("It will be rainy tomorrow", 3, 0, {value : 100})
    await bets.connect(acc2).setJudge()
    await bets.connect(acc3).setJudge()
    await bets.connect(acc4).setJudge()
    await bets.connect(acc5).register(false, {value: 100})
    await expect(bets.connect(acc5).register(false, {value: 100})).to.be.revertedWith("The address has already done his bet")
    await expect(bets.connect(acc1).register(false, {value: 100})).to.be.revertedWith("The address has already done his bet")
    await expect(bets.connect(acc2).register(false, {value: 100})).to.be.revertedWith("A judge cannot bet")
})

it("Checks the user setting revert is correct", async function(){
    await bets.connect(acc1).setHost("It will be rainy tomorrow", 2, 0, {value : 100})
    await bets.connect(acc2).setJudge()
    await bets.connect(acc3).setJudge()
    await bets.connect(acc4).setJudge()
    await expect(bets.connect(acc5).register(false, {value: 99})).to.be.revertedWith("Not enough money to enter the contest")
    await bets.connect(acc5).register(false, {value: 100})
    await expect(bets.connect(acc5).register(false, {value: 99})).to.be.revertedWith("There are too many players")
    await expect(bets.connect(acc5).register(false, {value: 99})).to.be.revertedWith("There are too many players")
})


it("Checks the game goes OK", async function(){
    await bets.connect(acc1).setHost("It will be rainy tomorrow", 2, 1, {value : 100})
    await bets.connect(acc2).setJudge()
    await bets.connect(acc3).setJudge()
    await bets.connect(acc4).setJudge()
    await bets.connect(acc5).register(false, {value: 100})
    await bets.connect(acc1).start()
    await time.increase(82000)
    await bets.connect(acc2).moveCommit('0x8f1a5e5f54d829a9d71008be78a93c0cf31d66e901caf59d91040bc25bfdce90')
    await bets.connect(acc3).moveCommit('0x1f9edb2b4f06d8470660b8bcd5ddc443a7eecf19cd7213f495a203db2c15ea57')
    await bets.connect(acc4).moveCommit('0xebf086d0d7e5779b28702e8c267f64d38d375f122166a7bb8a162fb47b78a0c2')
    await bets.connect(acc2).moveReveal(true, '0x41626f6261000000000000000000000000000000000000000000000000000000')
    bets.connect(acc3).moveReveal(true, '0x41626f6261000000000000000000000000000000000000000000000000000000')
    const temp = await bets.connect(acc4).moveReveal(true, '0x41626f6261000000000000000000000000000000000000000000000000000000')
    await expect(() =>temp).to.changeEtherBalance(acc2, 14)
    await expect(() =>temp).to.changeEtherBalance(acc3, 14)
    await expect(() =>temp).to.changeEtherBalance(acc4, 14)
    await expect(() =>temp).to.changeEtherBalance(acc1, 144)
    await expect(() =>temp).to.changeEtherBalance(bets, -186)
})

})