const { anyValue } = "@nomicfoundation/hardhat-chai-matchers/withArgs";
const { expect } = require("chai")
const { ethers } = require("hardhat")
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace")

describe("Other", function (){
    let acc1
    let acc2
    let game
    let other
beforeEach(async function(){
    [acc1, acc2] = await ethers.getSigners()
    const Game = await ethers.getContractFactory("Game", acc1)
    const Other = await ethers.getContractFactory("Other", acc1)
    game = await Game.deploy()
    other = await Other.deploy()
    await game.deployed()
    await other.deployed()
})

it("Checks the connection to other contract", async function(){
    await other.connect(acc1).otherSetHost(game.address)
    expect(await other.otherSetHostStatus()).to.eq(true)
})
it("checks the address", async function(){
    await game.setHost();
    const host = await game.checkHost();
    await other.otherExtractHost(game.address)
    const host2 = await other.otherGetHost()
    expect(host).to.eq(host2)
    await game.connect(acc2).setHost();
    const host3 = await game.checkHost();
    await other.otherExtractHost(game.address)
    const host4 = await other.otherGetHost()
    expect(host3).to.eq(host4)
})
})