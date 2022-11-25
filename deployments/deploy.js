const main  = async () => {
    const initialSupply = ethers.utils.parseEther("100000");

    const [deployer] = await ethers.getSigners();
    console.log(`Address deploying the contract --> ${deployer.address}`);

    const tokenFactory = await ethers.getContractFactory("Game");
    const contract = await tokenFactory.deploy();

    console.log(`Token contract address --> ${deployer.address}`);

}

main()
    .then(()=>process.exit(0))
    .catch((error) =>{console.error(error);
    process.exit(1);
    });