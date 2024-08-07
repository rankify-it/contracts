import { ethers } from 'hardhat';
import { Signer } from 'ethers';
import { expect } from 'chai';
import { CodeHashDistribution, CodeHashDistribution__factory, CodeIndex, TestFacet } from '../../types';
import hre, { deployments,  } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import utils from "../utils"


describe('CloneHashDistribution', function () {
  let codeIndex: CodeIndex;
  let deployer: SignerWithAddress;


  beforeEach(async function () {
    await deployments.fixture('code_index'); // This is the key addition
    const CodeIndex = await ethers.getContractFactory('CodeIndex');
    deployer = (await ethers.getSigners())[0];
    const codeIndexDeployment = await deployments.get('CodeIndex')
    codeIndex =  new ethers.Contract(codeIndexDeployment.address, CodeIndex.interface).connect(deployer) as CodeIndex;
  })

  it('Can instantiate a contract', async function () {
    const CutFacet = await ethers.getContractFactory('DiamondCutFacet');
    const cutFacet = await CutFacet.deploy();
    codeIndex.register(cutFacet.address);
    const CodeHashDistribution = await ethers.getContractFactory('CodeHashDistribution') as CodeHashDistribution__factory;
    const code = await cutFacet.provider.getCode(cutFacet.address);
    const codeHash = ethers.utils.keccak256(code);
    const codeHashDistribution = await CodeHashDistribution.deploy(codeHash, ethers.utils.formatBytes32String("DiamondProxy")) as CodeHashDistribution
    expect(await codeHashDistribution.instantiate()).to.emit(codeHashDistribution, "Distributed")
  })
  it('Instantiated contract code hash matches', async function () {
    const CutFacet = await ethers.getContractFactory('DiamondCutFacet');
    const cutFacet = await CutFacet.deploy();
    codeIndex.register(cutFacet.address);
    const CodeHashDistribution = await ethers.getContractFactory('CodeHashDistribution');
    const code = await cutFacet.provider.getCode(cutFacet.address);
    const codeHash = ethers.utils.keccak256(code);
    const codeHashDistribution = await CodeHashDistribution.deploy(codeHash,ethers.utils.formatBytes32String("DiamondProxy")) as CodeHashDistribution
    const receipt =await  (await codeHashDistribution.instantiate()).wait();

    // await codeIndex.register(instance.contractAddress)
    const superInterface = utils.getSuperInterface();
    const parsed = receipt.logs.map((log) => ({ rawLog: log, ...superInterface.parseLog(log) }));
    const instance = parsed[0].args.instances[0];
    const code2 = await cutFacet.provider.getCode(instance);
    expect(code2.slice(22,62).toLowerCase()).to.be.equal(cutFacet.address.slice(2).toLowerCase())
  })

});
