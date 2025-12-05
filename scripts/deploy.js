const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deployDiamond() {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]

  console.log('Deploying ERC20 Diamond with account:', contractOwner.address)

  // Deploy ERC20Init
  const ERC20Init = await ethers.getContractFactory('ERC20Init')
  const erc20Init = await ERC20Init.deploy()
  await erc20Init.deployed()
  console.log('ERC20Init deployed:', erc20Init.address)

  // Deploy facets
  const FacetNames = [
    'DiamondCutFacet',
    'DiamondLoupeFacet',
    'OwnershipFacet',
    'ERC20Facet',
    'ERC20MintBurnFacet'
  ]

  const facetCuts = []
  const facetAddresses = {}

  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy()
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)

    facetAddresses[FacetName] = facet.address
    facetCuts.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet)
    })
  }

  // Prepare initialization arguments
  const initArgs = {
    name: 'My Diamond Token',
    symbol: 'MDT',
    decimals: 18,
    initialSupply: ethers.utils.parseEther('1000000'), // 1 million tokens
    initialHolder: contractOwner.address
  }

  // Encode the init call
  const functionCall = erc20Init.interface.encodeFunctionData('init', [initArgs])

  // Diamond constructor arguments
  const diamondArgs = {
    owner: contractOwner.address,
    init: erc20Init.address,
    initCalldata: functionCall
  }

  // Deploy Diamond
  const Diamond = await ethers.getContractFactory('Diamond')
  const diamond = await Diamond.deploy(facetCuts, diamondArgs)
  await diamond.deployed()
  console.log('Diamond deployed:', diamond.address)

  return {
    diamondAddress: diamond.address,
    facetAddresses
  }
}

// Execute
if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
}

module.exports = { deployDiamond }