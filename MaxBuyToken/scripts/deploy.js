async function main() {
  const GameItems = await ethers.getContractFactory('GDCToken')
  const deployed = await GameItems.deploy()
  console.log('Contract deployed to:', deployed.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
